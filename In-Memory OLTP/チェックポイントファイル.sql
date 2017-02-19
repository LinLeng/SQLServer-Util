-- �`�F�b�N�|�C���g�t�@�C���̑S�̓��v
SELECT
	*
FROM
	sys.dm_db_xtp_checkpoint_stats


-- �`�F�b�N�|�C���g�t�@�C���g�p�� (�ڍ�)
SELECT 
	* 
FROM 
	sys.dm_db_xtp_checkpoint_files
ORDER BY
	container_guid ASC

-- �`�F�b�N�|�C���g�t�@�C���̃y�A���
SELECT
	T1.checkpoint_file_id, T1.relative_file_path, T1.file_type_desc, T1.file_size_in_bytes, T1.file_size_used_in_bytes, T1.logical_row_count,
	T2.checkpoint_file_id, T2.relative_file_path, T2.file_type_desc, T2.file_size_in_bytes, T2.file_size_used_in_bytes, T2.logical_row_count
FROM
	sys.dm_db_xtp_checkpoint_files T1
	INNER JOIN
	sys.dm_db_xtp_checkpoint_files T2
	ON
	T1.checkpoint_file_id = T2.checkpoint_pair_file_id
	AND
	T2.file_type_desc = 'DELTA'
WHERE
	T1.file_type_desc = 'DATA'


/*
-- SQL Server 2016 �ȍ~�́A�����}�[�W�|���V�[�ɂ�莩���I�Ƀt�@�C�����}�[�W�����
EXEC sys.sp_xtp_merge_checkpoint_files 
	@database_name = tpch, 
	@transaction_lower_bound=0, 
	@transaction_upper_bound = 100
*/
