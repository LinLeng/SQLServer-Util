-- ���� 6 ���Ԃ̏����擾
DECLARE @targetTime datetime
SET @targetTime = DATEADD(mm, -6, GETDATE())

-- �G�[�W�F���g�̎��s�����̏��̎擾
-- �G�[�W�F���g�W���u�͏���N����A�v���Z�X���풓���邽�߁A�W���u�̋N�����ł͂Ȃ��A���b�Z�[�W�̏o�͓����N�_�ɐݒ�

-- �f�B�X�g���r���[�V���� �G�[�W�F���g�̗������擾
SELECT 
	'distribution_agent' AS log_type,
	dh.time, 
	dh.start_time, 
	da.name,
	da.publisher_db,
	da.publication,
	da.subscriber_db,
	dh.comments,
	CASE dh.runstatus
		WHEN 1 THEN '�J�n'
		WHEN 2 THEN '����'
		WHEN 3 THEN '���s��'
		WHEN 4 THEN '�A�C�h�����'
		WHEN 5 THEN '�Ď��s'
		WHEN 6 THEN '���s'
		ELSE CAST(dh.runstatus AS sysname)
	END AS runstatus,
	dh.duration,
	dh.current_delivery_rate,
	dh.current_delivery_latency,
	dh.delivered_transactions,
	dh.delivered_commands,
	dh.average_commands,
	dh.delivery_rate,
	dh.delivery_latency,
	dh.total_delivered_commands,
	dh.error_id,
	dh.updateable_row,
	dh.xact_seqno
FROM 
	distribution.dbo.MSdistribution_history AS dh WITH(NOLOCK)
	LEFT JOIN 
		distribution.dbo.MSdistribution_agents AS da WITH(NOLOCK)
	ON
		da.id = dh.agent_id
WHERE
	dh.time >= @targetTime 
ORDER BY 
	dh.time DESC
OPTION (RECOMPILE, MAXDOP 1)


-- ���O���[�_�[ �G�[�W�F���g�̗������擾
SELECT 
	'logreader_agent' AS log_type,
	lh.time, 
	lh.start_time, 
	la.name,
	la.publisher_db,
	la.publication,
	lh.comments,
	CASE lh.runstatus
		WHEN 1 THEN '�J�n'
		WHEN 2 THEN '����'
		WHEN 3 THEN '���s��'
		WHEN 4 THEN '�A�C�h�����'
		WHEN 5 THEN '�Ď��s'
		WHEN 6 THEN '���s'
		ELSE CAST(lh.runstatus AS sysname)
	END as runstatus,
	lh.duration,
	lh.delivered_transactions,
	lh.delivered_commands,
	lh.average_commands,
	lh.delivery_rate,
	lh.delivery_latency,
	lh.error_id,
	lh.updateable_row,
	lh.xact_seqno
FROM 
	distribution.dbo.MSlogreader_history AS lh WITH(NOLOCK)
	LEFT JOIN
		distribution.dbo.MSlogreader_agents AS la WITH(NOLOCK)
	ON
		la.id = lh.agent_id
WHERE
	lh.time >= @targetTime
ORDER BY 
	lh.time DESC
OPTION (RECOMPILE, MAXDOP 1)

-- �X�i�b�v�V���b�g�G�[�W�F���g�̗������擾
SELECT 
	'snapshot_agent' AS log_type,
	sh.time, 
	sh.start_time, 
	sa.name,
	sa.publisher_db,
	sa.publication,
	sh.comments,
	CASE sh.runstatus
		WHEN 1 THEN '�J�n'
		WHEN 2 THEN '����'
		WHEN 3 THEN '���s��'
		WHEN 4 THEN '�A�C�h�����'
		WHEN 5 THEN '�Ď��s'
		WHEN 6 THEN '���s'
		ELSE CAST(sh.runstatus AS sysname)
	END as runstatus,
	sh.duration,
	sh.delivered_transactions,
	sh.delivered_commands,
	sh.delivery_rate,
	sh.error_id,*
FROM 
	distribution.dbo.MSsnapshot_history AS sh WITH (NOLOCK)
	LEFT JOIN
		distribution.dbo.MSsnapshot_agents AS sa WITH(NOLOCK)
	ON
		sa.id = sh.agent_id
WHERE
	sh.time >= @targetTime
ORDER BY 
	sh.time DESC
OPTION (RECOMPILE, MAXDOP 1)