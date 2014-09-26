if (exists (select * from sys.objects where name = 'proc_zjlx'))
    drop proc proc_zjlx
go
create proc proc_zjlx
	@start_date NCHAR(128),
	@end_date NCHAR(128),
	@start_ordi int, 
	@end_ordi int,
	@rise_limit real,
	@buy_hour int,
	@buy_min int
as

SELECT [DT],[Ordi],[S],[P],[R] FROM [Dfcf].[dbo].[1DAY] 
	WHERE  DT >= @start_date AND DT <=@end_date and Ordi > @start_ordi AND Ordi < @end_ordi AND R < @rise_limit 
	ORDER BY DT

SELECT [DT],[Ordi],[S],[P],[R] FROM [Dfcf].[dbo].[1DAY] 
	WHERE  DT >= @start_date and Ordi > @start_ordi AND Ordi < @end_ordi AND R < @rise_limit 
	ORDER BY DT
	
-- get unique date to var_unqique_date
SELECT DISTINCT CONVERT(date, DT) DT 
	into #var_unique_date
	FROM [Dfcf].[dbo].[1DAY] 
	WHERE  DT >= @start_date and DT <= @end_date
	ORDER BY CONVERT(date, DT)

select * from #var_unique_date


