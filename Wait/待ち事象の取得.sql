SET NOCOUNT ON
GO

/*********************************************/
-- Wait Stats �̎擾
/*********************************************/
-- WAITSTATS �̎擾
-- DBCC SQLPERF('sys.dm_os_wait_stats', clear)
SELECT
	GETDATE() AS [DateTime], 
	[wait_type], 
	[waiting_tasks_count], 
	[wait_time_ms], 
	[max_wait_time_ms], 
	[signal_wait_time_ms]
FROM
	[sys].[dm_os_wait_stats]
ORDER BY
	[wait_time_ms] DESC
OPTION (RECOMPILE)

	
/*********************************************/
-- LATCHSTATS �̎擾
/*********************************************/
-- DBCC SQLPERF('sys.dm_os_latch_stats', clear)
SELECT
	*
FROM
	[sys].[dm_os_latch_stats]
OPTION (RECOMPILE)

/*********************************************/
-- SpinLock Stats �̎擾 (SQL Server 2008 �ȍ~)
/*********************************************/
-- DBCC SQLPERF('sys.dm_os_spinlock_stats', clear)
SELECT
	*
FROM
	[sys].[dm_os_spinlock_stats]
OPTION (RECOMPILE)

