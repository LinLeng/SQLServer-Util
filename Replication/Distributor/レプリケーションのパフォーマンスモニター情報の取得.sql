-- �l�����̂܂ܗ��p�\�ȍ���
SELECT 
	*
FROM 
	sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
	object_name LIKE '%:Replication%'
	AND
	cntr_type = 65792
OPTION (RECOMPILE, MAXDOP 1)
GO

-- 2 �_�Œl���擾���A���̍������擾�Ԋu�Ŋ��鍀��
SELECT 
	*
FROM 
	sys.dm_os_performance_counters  WITH(NOLOCK)
WHERE
	object_name LIKE '%:Replication%'
	AND
	cntr_type = 272696576
OPTION (RECOMPILE, MAXDOP 1)
GO
