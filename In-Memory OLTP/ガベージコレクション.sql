SELECT * FROM sys.dm_db_xtp_gc_cycle_stats
SELECT * FROM sys.dm_xtp_gc_queue_stats
SELECT * FROM sys.dm_xtp_gc_stats

-- �蓮�� GC ���s
EXEC sys.sp_xtp_checkpoint_force_garbage_collection