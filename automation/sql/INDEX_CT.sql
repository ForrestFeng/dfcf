USE [Dfcf]
GO

/****** Object:  Table [dbo].[INDEX]    Script Date: 09/13/2014 14:11:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INDEX]') AND type in (N'U'))
DROP TABLE [dbo].[INDEX]
GO

USE [Dfcf]
GO

/****** Object:  Table [dbo].[INDEX]    Script Date: 09/13/2014 14:11:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[INDEX](
	DT		DateTime NOT NULL, --DateTime
	Ordi		INT NOT NULL,
	S		INT NOT NULL,
	N		NCHAR(128) NULL,
	P		REAL NULL,
	R		REAL NULL,
	RP		REAL NULL,
	A		REAL NULL,
	H		REAL NULL,
	L		REAL NULL,
	O		REAL NULL,
	LC		REAL NULL,
	CONSTRAINT pk_INDEX PRIMARY KEY (DT,S)
)ON [PRIMARY]

GO


