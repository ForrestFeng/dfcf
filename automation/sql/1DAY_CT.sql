USE [Dfcf]
GO

/****** Object:  Table [dbo].[1DAY]    Script Date: 09/15/2014 22:35:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[1DAY]') AND type in (N'U'))
DROP TABLE [dbo].[1DAY]
GO

USE [Dfcf]
GO

/****** Object:  Table [dbo].[1DAY]    Script Date: 09/15/2014 22:35:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[1DAY](
	DT		DateTime NOT NULL, --DateTime
	Ordi		INT NOT NULL,
	S		INT NOT NULL,
	N		NCHAR(128) NULL,
	P		REAL NULL,
	R		REAL NULL,
	InNet		REAL NULL,
	InNetP		REAL NULL,
	TDN		REAL NULL,
	TDP		REAL NULL,
	DN		REAL NULL,
	DP		REAL NULL,
	MN		REAL NULL,
	MP		REAL NULL,
	SN		REAL NULL,
	SP		REAL NULL,
	CONSTRAINT pk_1DAY PRIMARY KEY (DT,S)
)ON [PRIMARY]


GO


