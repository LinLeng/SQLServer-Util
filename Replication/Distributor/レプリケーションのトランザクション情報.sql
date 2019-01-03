SELECT TOP 200
	dh.time,
	pd.publisher_db,
	CASE dh.runstatus
		WHEN 1 THEN '�J�n'
		WHEN 2 THEN '����'
		WHEN 3 THEN '���s��'
		WHEN 4 THEN '�A�C�h��'
		WHEN 5 THEN '�Ď��s'
		WHEN 6 THEN '���s'
	END AS runstatus,
	rt.entry_time,
	dh.start_time,
	dh.xact_seqno,
	dh.comments,
	dh.duration,
	dh.current_delivery_rate,
	dh.current_delivery_latency,
	dh.delivered_commands,
	dh.average_commands,
	dh.delivery_latency,
	dh.total_delivered_commands,
	dh.error_id
FROM 
	distribution.dbo.MSrepl_transactions AS rt
	LEFT JOIN
	distribution.dbo.MSdistribution_history AS dh
	ON
	dh.xact_seqno = rt.xact_seqno
	LEFT JOIN
	distribution.dbo.MSpublisher_databases AS pd
	ON
	pd.id = rt.publisher_database_id
WHERE
	dh.time IS NOT NULL
ORDER BY
	dh.time DESC