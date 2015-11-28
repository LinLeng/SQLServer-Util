/********************************************************************************/
-- �g���C�x���g�ŃN�G�������擾����ۂ̃x�[�X�e���v���[�g
-- �蓮�J�n�ɂ�郉�C�u���j�^�[�݂̂̐ݒ�̂��߁A�^�[�Q�b�g�⎩���J�n��K�X�ݒ�
/********************************************************************************/
-- ���b�N���������������N�G�� (blocked prosess threshold �̐ݒ肪�K�v)
-- ���������̑ҋ@�� 1 �b�ȏ㔭�������N�G��
-- �n�b�V���������̃������s�������������N�G��
-- ���v���ݒ肳��Ă��Ȃ���ɑ΂��Ď��s���ꂽ�N�G��
-- �\�[�g���Ƀ������s�������������N�G��
-- ���s�� 10 �b�ȏォ�������N�G��
-- �f�b�h���b�N���|�[�g/�f�b�h���b�N�`�F�[��
/********************************************************************************/
CREATE EVENT SESSION [Query_Trace] ON SERVER 
ADD EVENT sqlserver.blocked_process_report,
ADD EVENT sqlserver.execution_warning(SET collect_server_memory_grants=(1)
    ACTION(sqlserver.sql_text)),
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)),
ADD EVENT sqlserver.lock_deadlock_chain(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)),
ADD EVENT sqlserver.missing_column_statistics(SET collect_column_list=(1)
    ACTION(sqlserver.sql_text)),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    WHERE ([duration]>=(10000000))),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlserver.sql_text))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


