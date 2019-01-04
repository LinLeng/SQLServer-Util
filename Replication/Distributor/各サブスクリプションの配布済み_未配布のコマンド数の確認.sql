WITH distribution_history AS
(
	SELECT
		*
	FROM
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY agent_id ORDER BY time DESC) AS No,
			* 
		FROM 
			distribution.dbo.MSdistribution_history
	) AS T
	WHERE No = 1
), job_info AS
(
SELECT 
	sj.step_uid,
	sj.step_id,
	sj.subsystem,
	sj.command,
	CASE ss.freq_type
		WHEN 1 THEN '1 ��̂�'
		WHEN 4 THEN '����'
		WHEN 8 THEN '���T'
		WHEN 16 THEN '����'
		WHEN 32 THEN '���� (���Ύw��)'
		WHEN 64 THEN '�N���� (�A�����s)'
		WHEN 128 THEN '�A�C�h����'
		ELSE CAST(ss.freq_type AS sysname)
	END AS freq_type
FROM 
	msdb.dbo.sysjobsteps AS sj WITH(NOLOCK)
	LEFT JOIN
		msdb.dbo.sysjobschedules AS sjs WITH(NOLOCK)
	ON
		sjs.job_id = sj.job_id
	LEFT JOIN
		 msdb.dbo.sysschedules AS ss WITH(NOLOCK)
	ON
		ss.schedule_id = sjs.schedule_id
)

SELECT 
	dh.time,
	p.publication AS publication_name,
	a.article,
	sr_p.msrs_srvname AS publisher_server,
	s.publisher_db,
	sr_s.msrs_srvname AS subscliber_server,
	s.subscriber_db,
	a.source_owner + '.' + a.source_object AS source_object,
	CASE
		WHEN a.destination_owner IS NULL THEN  a.destination_object 
		ELSE destination_owner + '.' + destination_object
	END AS destination_object,
	CASE s.subscription_type
		WHEN 0 THEN 'Push'
		WHEN 1 THEN 'Pull'
		WHEN 2 THEN 'Anonymous'
		ELSE CAST(s.subscription_type AS sysname)
	END AS subscription_type,
	da.local_job,
	ji.freq_type,
	CASE s.sync_type 
		WHEN 1 THEN '����'
		WHEN 2 THEN '��������(�蓮����)'
		ELSE CAST(s.sync_type AS sysname)
	END AS sync_type,
	CASE dh.runstatus
		WHEN 1 THEN '�J�n'
		WHEN 2 THEN '����'
		WHEN 3 THEN '���s��'
		WHEN 4 THEN '�A�C�h�����'
		WHEN 5 THEN '�Ď��s'
		WHEN 6 THEN '���s'
		ELSE CAST(dh.runstatus AS sysname)
	END as runstatus,
	dh.comments,
	dh.error_id,
	re.error_detail,
	ds.UndelivCmdsInDistDB,
	ds.DelivCmdsInDistDB,
	dh.total_delivered_commands,
	dh.delivered_transactions,
	dh.delivered_commands,
	dh.average_commands,
	dh.current_delivery_latency AS current_delivery_latency_ms, --- command/sec
	dh.current_delivery_rate AS current_delivery_rate_ms, -- msec
	dh.current_delivery_latency AS current_delivery_latency_ms, -- msec
	da.name AS agent_name,
	p.description,
	ji.command,
	da.subscriber_login,
	s.subscription_time AS snapshot_subscription_time, 
	s.snapshot_seqno_flag, 
	s.subscription_seqno AS snapshot_subscription_seq_no
FROM 
	distribution.dbo.MSsubscriptions  AS s WITH (NOLOCK)
	LEFT JOIN distribution.dbo.MSdistribution_status AS ds WITH (NOLOCK)
	ON
		s.agent_id =ds.agent_id AND s.article_id = ds.article_id
	LEFT JOIN distribution.dbo.MSarticles AS a WITH (NOLOCK)
	ON 
		a.publisher_db = s.publisher_db AND
		a.article_id = s.article_id
	LEFT JOIN distribution.dbo.MSdistribution_agents AS da WITH (NOLOCK)
	ON
		da.id = ds.agent_id
	LEFT JOIN distribution.dbo.MSsysservers_replservers AS sr_p WITH(NOLOCK)
	ON
		sr_p.msrs_srvid = s.publisher_id
	LEFT JOIN distribution.dbo.MSsysservers_replservers AS sr_s WITH(NOLOCK)
	ON
		sr_s.msrs_srvid = s.subscriber_id
	LEFT JOIN distribution.dbo.MSpublications AS p WITH(NOLOCK)
	ON
		p.publication_id = s.publication_id
	LEFT JOIN distribution_history AS dh WITH(NOLOCK)
	ON
		dh.agent_id = s.agent_id
	CROSS APPLY
	(
		SELECT
			error_text + '|' 
		FROM	
			distribution.dbo.MSrepl_errors AS re WITH (NOLOCK)
		WHERE
			re.id = dh.error_id
		FOR XML PATH('')
	) AS re (error_detail)
	LEFT JOIN job_info AS ji WITH(NOLOCK)
	ON
	ji.step_uid = da.job_step_uid
WHERE 
	s.subscriber_id > 0
ORDER BY
	s.publication_id ASC,
	a.article ASC,
	s.subscriber_db ASC
OPTION (RECOMPILE, MAXDOP 1)