USE [Dfcf]
GO

/****** Object:  Table [dbo].[ZJLX]    Script Date: 09/13/2014 13:39:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BS]') AND type in (N'U'))
DROP TABLE [dbo].[BS]
GO

USE [Dfcf]
GO

/****** Object:  Table [dbo].[ZJLX]    Script Date: 09/13/2014 13:39:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON

GO
CREATE TABLE [dbo].[BS](
	S   INT NOT NULL,
	N	NCHAR(128) NULL,
	
	DT1		DateTime NULL, --DateTime
	Ordi1		INT NULL, 	
	P1		REAL NULL,
	R1		REAL NULL,	
	
	DT2		DateTime NULL, --DateTime
	Ordi2		INT NULL, 
	P2		REAL NULL,
	R2		REAL NULL,	
	
	DT3		DateTime  NULL, --DateTime
	Ordi3		INT  NULL, 
	P3		REAL NULL,
	R3		REAL NULL
)ON [PRIMARY]

GO


