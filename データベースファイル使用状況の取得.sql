SET NOCOUNT
ON
/*********************************************/
--  �f�[�^�x�[�X�t�@�C���̎g�p�󋵂̊m�F
/*********************************************/
CREATE TABLE [#TmpTbl]
(
   [Fileid] SMALLINT,
   [FileGroup] SMALLINT,
   [TotalExtents] BIGINT,
   [UsedExtents] BIGINT,
   [Name] nchar(128),
   [FileName] nchar(260)
)

EXEC sp_Msforeachdb '
INSERT INTO 
[#TmpTbl]
EXECUTE 
(''USE [?];DBCC SHOWFILESTATS WITH NO_INFOMSGS'')
'
SELECT 
DB_NAME([sys].[master_files].[database_id]) AS [DB Name], 
[sys].[master_files].[file_id],
[sys].[master_files].[data_space_id] AS [FileGroup ID], 
([sys].[master_files].[size] * 8192.0) / 1024.0 AS [File Size(KB)], 
COALESCE([#TmpTbl].[TotalExtents], '') AS [TotalExtents], 
COALESCE([#TmpTbl].[UsedExtents], '') AS [UsedExtents], 
CASE
WHEN [#TmpTbl].[UsedExtents] IS NULL THEN
COALESCE(NULL, '')
ELSE
([#TmpTbl].[UsedExtents] * 8192 * 8) / 1024
END AS [UsedExtents(KB)], 
[sys].[master_files].[max_size],  -- -1:�����Ȃ�, 0:�e�ʌŒ�, ����ȊO�ő�T�C�Y
[sys].[master_files].[growth], 
[sys].[master_files].[is_percent_growth],
[sys].[master_files].[name], 
[sys].[master_files].[physical_name]
FROM
[sys].[master_files] WITH (NOLOCK)
LEFT JOIN
[#TmpTbl] WITH (NOLOCK)
ON
[#TmpTbl].[Fileid] = [sys].[master_files].[file_id]
AND
[#TmpTbl].[FileGroup] = [sys].[master_files].[data_space_id]
AND
[#TmpTbl].[Name] = [sys].[master_files].[name]
AND
[#TmpTbl].[FileName] = [sys].[master_files].[physical_name]
ORDER BY 
[sys].[master_files].[database_id] ASC,
[sys].[master_files].[file_id] ASC, 
[sys].[master_files].[data_space_id] ASC

DROP TABLE [#TmpTbl]


/*********************************************/
--  ���O�t�@�C���̎g�p�󋵂̊m�F
/*********************************************/
DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS

