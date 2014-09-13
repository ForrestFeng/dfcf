USE [Dfcf]
GO

/****** Object:  Table [dbo].[ZCPM]    Script Date: 09/13/2014 14:12:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZCPM]') AND type in (N'U'))
DROP TABLE [dbo].[ZCPM]
GO

USE [Dfcf]
GO

/****** Object:  Table [dbo].[ZCPM]    Script Date: 09/13/2014 14:12:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ZCPM](
	DT		DateTime NOT NULL, --DateTime
	Ordi		INT NOT NULL,
	S		INT NOT NULL,
	N		NCHAR(128) NULL,
	P		REAL NULL,
	R		REAL NULL,
	Ind		NCHAR(128) NULL,
	WPct		REAL NULL,
	Rnk		REAL NULL,
	RnkChg		REAL NULL,
	R1		REAL NULL,
	WPct3		REAL NULL,
	Rnk3		REAL NULL,
	RnkChg3		REAL NULL,
	R3		REAL NULL,
	WPct5		REAL NULL,
	Rnk5		REAL NULL,
	RnkChg5		REAL NULL,
	R5		REAL NULL,
	WPct10		REAL NULL,
	Rnk10		REAL NULL,
	RnkChg10		REAL NULL,
	R10		REAL NULL,
	CONSTRAINT pk_ZCPM PRIMARY KEY (DT,S)
)ON [PRIMARY]


GO


