SET NOCOUNT ON
GO

USE [master]
GO
/*********************************************/
-- �t�@�C�� IO �̎擾
-- sys.dm_io_virtual_file_stats �ł��\
/*********************************************/
SELECT
	GETDATE() AS [DateTime],
	DB_NAME([sys].[master_files].[database_id]) AS [DatabaseName], 
	[sys].[master_files].[name], 
	[sys].[master_files].[physical_name], 
	[fn_virtualfilestats].[NumberReads],
	[fn_virtualfilestats].[IoStallReadMS],
	[fn_virtualfilestats].[BytesRead], 
	[fn_virtualfilestats].[NumberWrites], 
	[fn_virtualfilestats].[IoStallWriteMS],
	[fn_virtualfilestats].[BytesWritten], 
	[fn_virtualfilestats].[BytesOnDisk]
FROM
	fn_virtualfilestats(NULL, NULL)
	LEFT JOIN
	[sys].[master_files]  WITH (NOLOCK)
	ON
		fn_virtualfilestats.DbId = [sys].[master_files].[database_id]
		AND
		fn_virtualfilestats.FileId = [sys].[master_files].[file_id]
OPTION (RECOMPILE)
		
/*********************************************/
-- IO ���N�G�X�g�̑҂��̔����󋵂̎擾
/*********************************************/
SELECT * FROM sys.dm_io_pending_io_requests
OPTION (RECOMPILE)


