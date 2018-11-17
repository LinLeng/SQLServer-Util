DECLARE @system bit = 1							-- �V�X�e���Z�b�V�������擾 (0: ���ׂẴZ�b�V�������擾 / 1 : SPID >= 50 ���擾)
DECLARE @elapsed_time_ms int = 0				-- ���s���牽�b�o�߂��Ă���N�G�����擾���邩 (0 : ���ׂ�)
DECLARE @wait_time_ms int = 0					-- ���b�ҋ@���������Ă���N�G�����擾���邩 (0 : ���ׂ�)
DECLARE @transaction_elapsed_time_ms int = 0	-- �g�����U�N�V�����J�n�����a�o�߂��Ă���N�G�����擾���邩 (0 : ���ׂ�)

SELECT * FROM(
SELECT 
	es.session_id,
	es.program_name,
	es.status,
	er.command,
	
	er.blocking_session_id,

	er.wait_type,
	er.last_wait_type,
	er.wait_resource,

	COALESCE(DATEDIFF(MILLISECOND, er.start_time, GETDATE()), 0) AS elapsed_time_ms, 
	COALESCE(er.wait_time, 0) AS wait_time_ms,
	COALESCE(DATEDIFF(MILLISECOND, tat.transaction_begin_time, GETDATE()), 0) AS transaction_begin_elapsed_time_ms, 
	COALESCE(DATEDIFF(MILLISECOND, es.login_time, GETDATE()), 0) AS login_elapsed_time_ms, 
	COALESCE(DATEDIFF(MILLISECOND, es.last_request_start_time, GETDATE()), 0) AS last_request_start_elapsed_time_ms, 
	COALESCE(DATEDIFF(MILLISECOND, es.last_request_end_time, GETDATE()), 0) AS last_request_end_elapsed_time_ms, 

	es.login_time,
	es.last_request_start_time,
	es.last_request_end_time,
	er.start_time,
	tat.transaction_begin_time,

	DB_NAME(er.database_id) AS database_name,

	es.host_name,
	es.login_name,

	SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
	((CASE er.statement_end_offset  
		WHEN -1 THEN DATALENGTH(st.text)  
		ELSE er.statement_end_offset  
		END - er.statement_start_offset)/2) + 1) AS statement_text ,
	st.text,
	qp.query_plan

FROM
	sys.dm_exec_sessions AS es  WITH(NOLOCK)
	LEFT JOIN sys.dm_exec_requests AS er  WITH(NOLOCK) ON er.session_id = es.session_id
	LEFT JOIN sys.dm_tran_active_transactions AS tat WITH(NOLOCK) ON tat.transaction_id = er.transaction_id
	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp  
	OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st 
) AS T
WHERE
	session_id <> @@SPID
	AND
	session_id >= 
		CASE @system
			WHEN 0 THEN 50 -- ���[�U�[�Z�b�V�������݂̂��擾
			ELSE 0	-- �V�X�e���Z�b�V�����𕹂��Ď擾
		END
	AND
	elapsed_time_ms >= @elapsed_time_ms
	AND
	transaction_begin_elapsed_time_ms >= @transaction_elapsed_time_ms
	AND
	wait_time_ms >= @wait_time_ms
ORDER BY
	session_id
OPTION (MAXRECURSION 100, RECOMPILE)