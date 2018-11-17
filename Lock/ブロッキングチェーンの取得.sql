DECLARE @headblocker bit = 0	-- HeadBlocker �݂̂��擾���邩
DECLARE @level int = 100		-- �����x���܂Ŏ擾���邩

;WITH 
-- �v���Z�X�ꗗ
sp AS(
	SELECT spid, blocked, cmd, lastwaittype,waitresource,status, text 
	FROM sys.sysprocesses 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle)
	WHERE spid > 50
),
-- �u���b�L���O���X�g
BlockList AS(

--  Blocker
SELECT
	spid, 
	CAST(blocked AS varchar(100)) AS blocked,
	1 AS level, 
	1 AS is_HeadBlocker,
	CAST(RIGHT(REPLICATE('0', 8) + CAST(spid AS varchar(10)), 8) AS varchar(100)) AS blocked_chain,
	CAST('' AS varchar(100)) AS blocked_path, 
	RTRIM(cmd) AS cmd,
	RTRIM(lastwaittype) AS lastwaittype,
	RTRIM(waitresource) AS waitresource,
	RTRIM(status) AS status
	,text
FROM
	sp
WHERE
	blocked = 0
	AND
	spid in (SELECT blocked FROM sp WHERE blocked <> 0)
UNION ALL

--  Blocked
SELECT
	r.spid, 
	CAST(r.blocked AS varchar(100)),
	BlockList.level + 1 AS level,
	0 AS is_HeadBlocker,
	CAST(BlockList.blocked_chain + CAST(r.spid AS varchar(10)) AS varchar(100)) AS blocked_chain,
	CAST(
		CASE BlockList.blocked_path 
		WHEN '' THEN CAST(BlockList.spid AS varchar(10))
		ELSE BlockList.blocked_path + '->' + CAST(r.blocked AS varchar(10)) 
		END
		AS varchar(100)
	) , 
	RTRIM(r.cmd) AS cmd,
	RTRIM(r.lastwaittype) AS lastwaittype,
	RTRIM(r.waitresource) AS waitresource,
	RTRIM(r.status) AS status,
	r.text
FROM
	sp r
	INNER JOIN
	BlockList
	ON
	r.blocked = BlockList.spid
)
-- �u���b�L���O���̎擾
SELECT 
	BlockList.level, 
	BlockList.spid, 
	is_HeadBlocker,
	CASE 
		WHEN BlockList.blocked_path = '' THEN ''
		ELSE BlockList.blocked_path + '->' + CAST(BlockList.spid AS varchar(10))
	END	AS blocked_path,
	er.start_time,
	at.transaction_begin_time,
	datediff(MILLISECOND, er.start_time,GETDATE()) AS epalsed_time_ms,
	at.name AS transaction_name,
	CASE at.transaction_type -- �ǂݎ���p�g�����U�N�V�����̃g�����U�N�V�����o�ߎ��Ԃ̓g�����U�N�V������͂̃m�C�Y�ɂȂ�\�������邽�߁AElapsed �Ŕ��f
		WHEN 2 THEN NULL
		ELSE datediff(MILLISECOND, at.transaction_begin_time, GETDATE())
	END AS transaction_elapsed_time_ms,
	er.wait_time,
	er.status,
	BlockList.cmd, 
	er.wait_type,
	BlockList.lastwaittype, 
	er.wait_resource AS er_wait_resource,
	BlockList.waitresource AS BlockList_wait_resource, 
	BlockList.status, 
	es.host_name,
	es.program_name,
	es.login_name,
	er.open_transaction_count,
	CASE at.transaction_type
		WHEN 1 THEN N'�ǂݎ��/��������'
		WHEN 2 THEN N'�ǂݎ���p'
		WHEN 3 THEN N'�V�X�e��'
		WHEN 4 THEN N'���U�g�����U�N�V����'
		ELSE CAST(at.transaction_type AS nvarchar(50))
	END AS transaction_type,
	CASE at.transaction_state
		WHEN 1 THEN N'�������҂�'
		WHEN 1 THEN N'�J�n�҂�'
		WHEN 2 THEN N'�A�N�e�B�u'
		WHEN 3 THEN N'�I��'
		WHEN 4 THEN N'���U�g�����U�N�V�����R�~�b�g�J�n'
		WHEN 5 THEN N'�����҂�'
		WHEN 6 THEN N'�R�~�b�g����'
		WHEN 7 THEN N'���[���o�b�N��'
		WHEN 8 THEN N'���[���o�b�N����'
		ELSE CAST(at.transaction_type AS nvarchar(50))
	END AS transaction_state,		at.transaction_id,
	at.transaction_uow,
	BlockList.text,
		SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
	((CASE er.statement_end_offset  
		WHEN -1 THEN DATALENGTH(st.text)  
		ELSE er.statement_end_offset  
		END - er.statement_start_offset)/2) + 1) AS statement_text ,
	st.text AS st_text,
	qp.query_plan
FROM 
	BlockList
	LEFT JOIN sys.dm_exec_requests AS er ON er.session_id = BlockList.spid
	LEFT JOIN sys.dm_tran_active_transactions AS at ON at.transaction_id = er.transaction_id
	LEFT JOIN sys.dm_exec_sessions as es ON es.session_id = BlockList.spid
	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
	OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
WHERE
	is_HeadBlocker >= @headblocker
	AND
	level BETWEEN 1 AND @level
ORDER BY 
	level ASC,
	blocked_chain ASC,
	spid 
	ASC
OPTION (MAXRECURSION 100, RECOMPILE)