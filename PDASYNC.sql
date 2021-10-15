IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Cs2cn_Prk_PDASyncDetails_QS' AND XTYPE ='U')
DROP TABLE Cs2cn_Prk_PDASyncDetails_QS
GO
CREATE TABLE Cs2cn_Prk_PDASyncDetails_QS
(
       [SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
       [DistCode] [nvarchar](100) NULL,
       [FixId] [int] NULL,
       [FixDate] [datetime] NULL,
       [UploadFlag] [nvarchar](1) NULL,
       [SyncId] [numeric](38, 0) NULL,
       [PDASyncDate] [datetime] NULL,--- New Column
       [PDASyncStatus] [varchar](50) NULL,--- New Column
       [PDASyncId] [int] NULL,--- New Column
       [PDASyncVersion] [varchar](50) NULL,--- New Column
       [ServerDate] [datetime] NULL
) ON [PRIMARY]
GO


1009798