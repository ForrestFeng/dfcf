USE [Dfcf]
GO

/****** Object:  Table [dbo].[CWSJ]    Script Date: 09/13/2014 14:09:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CWSJ]') AND type in (N'U'))
DROP TABLE [dbo].[CWSJ]
GO

USE [Dfcf]
GO

/****** Object:  Table [dbo].[CWSJ]    Script Date: 09/13/2014 14:09:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CWSJ](
	DT		DateTime NOT NULL, --DateTime
	Ordi		INT NOT NULL,
	S		INT NOT NULL, 
	N		NCHAR(128) NULL,
	RptDate		DateTime  NULL,
	TSC		REAL NULL,
	[ASC]		REAL NULL,
	SharePerPerson		REAL NULL,
	EPS		REAL NULL,
	NAPS		REAL NULL,
	ROE		REAL NULL,
	Rev		REAL NULL,
	RevYoy		REAL NULL,
	Profit		REAL NULL,
	InvestProfit		REAL NULL,
	TotalProfit		REAL NULL,
	NetProfit		REAL NULL,
	NetProfitYoy		REAL NULL,
	UndisProfit		REAL NULL,
	UndisProfitPerShare		REAL NULL,
	MarginRate		REAL NULL,
	TotalAssets		REAL NULL,
	CurrentAssets		REAL NULL,
	FixedAssets		REAL NULL,
	IntangibleAssets		REAL NULL,
	TotalLiabilities		REAL NULL,
	CurrentLiabilities		REAL NULL,
	LongtermLiabilities		REAL NULL,
	LiabilityAssetRatio		REAL NULL,
	Equity		REAL NULL,
	EquityRatio		REAL NULL,
	ReserveFunds		REAL NULL,
	ReserveFundsPerShare		REAL NULL,
	BSC		REAL NULL,
	HSC		REAL NULL,
	IPODate		DateTime  NULL,
	CONSTRAINT pk_CWSJ PRIMARY KEY (DT,S)
)ON [PRIMARY]
GO


