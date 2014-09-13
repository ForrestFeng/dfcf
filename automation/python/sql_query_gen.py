
def gen_create_table_query(tab_sep_header, table_name):
    ss = tab_sep_header.split()
    print('CREATE TABLE [dbo].[{0}]('.format(table_name))
    for s in ss:
        if s == 'DT':
            print('\tDT\t\tDateTime NOT NULL, --DateTime')
        elif s == 'S':
            print('\tS\t\tINT NOT NULL,')
        elif s == 'Ordi':
            print('\tOrdi\t\tINT NOT NULL,')
        elif s == 'N':
            print('\tN\t\tNCHAR(128) NULL,')
        elif s == 'Ind':
            print('\tInd\t\tNCHAR(128) NULL,')
        elif 'Date' in s:
            print('\t{}\t\tDateTime  NULL,'.format(s))
        else:
            print('\t{}\t\tREAL NULL,'.format(s))
    print('\tCONSTRAINT pk_{} PRIMARY KEY (DT,S)'.format(table_name))
    print(')ON [PRIMARY]')



zjlx_header = "DT   Ordi	S	N	P	R	InNet	AA	TDI	TDO	TDN	TDP	DI	DO	DN	DP	MI	MO	MN	MP	SI	SO	SN	SP"
gen_create_table_query(zjlx_header, 'ZJLX')

print()
zcpm_header = "DT   Ordi	S	N	P	R	Ind	WPct	Rnk	RnkChg	R1	WPct3	Rnk3	RnkChg3	R3	WPct5	Rnk5	RnkChg5	R5	WPct10	Rnk10	RnkChg10	R10"
gen_create_table_query(zcpm_header, 'ZCPM')

print()
dde_header = "DT   Ordi	S	N	P	R	DDX	DDY	DDZ	DDX5	DDY5	DDX10	DDY10	LX	D5	D10	TDS	TDB	TDN	DB	DS	DN"
gen_create_table_query(dde_header, 'DDE')

print()
index_header = "DT   Ordi	S	N	P	R	RP	A	H	L	O	LC"
gen_create_table_query(index_header, 'INDEX')


print()
cwsj_header = "DT   Ordi	S	N	RptDate	TSC	ASC	SharePerPerson	EPS	NAPS	ROE	Rev	RevYoy	Profit	InvestProfit	TotalProfit	NetProfit	NetProfitYoy	UndisProfit	UndisProfitPerShare	MarginRate	TotalAssets	CurrentAssets	FixedAssets	IntangibleAssets	TotalLiabilities	CurrentLiabilities	LongtermLiabilities	LiabilityAssetRatio	Equity	EquityRatio	ReserveFunds	ReserveFundsPerShare	BSC	HSC	IPODate"
gen_create_table_query(cwsj_header, 'CWSJ')