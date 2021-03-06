--调用、执行存储过程
--exec proc_zjlx '2014-08-13', '2014-09-13', 0, 20, 9.0, 13, 20
Use Dfcf
GO
-- drop the BS table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BS]') AND type in (N'U'))
delete from [dbo].[BS]
go



-- make a data cursor
declare @beginDate	 nchar(128)
declare @endDate   nchar(128)
declare @curDate nchar(128)
declare @nextDate nchar(128)
declare @sellTime nchar(128)
declare @ordiMin int
declare @ordiMax int
declare @rLimit real
declare @holdDays int


set @beginDate =  '2014-08-13'
set @endDate = '2014-09-25'
set @sellTime = '15:00:00'
set @ordiMin = 0
set @ordiMax = 11
set @rLimit = 5
set @holdDays = 1

--close dateCursor
--deallocate dateCursor


declare   dateCursor SCROLL cursor for select distinct convert(date, DT) from [1DAY] --@tableName 
	where convert(date, DT) >= @beginDate and convert(date, DT) <= @endDate order by convert(date, DT) asc


open dateCursor
fetch next from dateCursor into @curDate 

while @@fetch_status=0 
begin
	-- get the 
	fetch next from dateCursor into @nextDate
	print 'base and now date:'
	print convert(date, @curDate)
	print convert(date, @nextDate)
	
	if @@fetch_status <> 0 
	begin
		break
	end
	
	-- find the strong stocks for the two days, #curTable stores reference stock
	-- #buyTable stores the stock for today	
	IF OBJECT_ID('tempdb..#curTable','U') IS NOT NULL DROP TABLE #curTable
	select DT, Ordi, N, P, S, R into #curTable from [1DAY] 
		where convert(date, DT)= @curDate and Ordi >= 10 and Ordi <= 200 and R <= @rLimit and R > 0  and convert(time, DT) > '09:00:00'
	
	IF OBJECT_ID('tempdb..#buyTable','U') IS NOT NULL DROP TABLE #buyTable
	select DT, Ordi, P, S, R into #buyTable from [1DAY] 
		where convert(date, DT)= @nextDate and Ordi >= 0 and Ordi <= 10 and R <= @rLimit and R > 0 	and convert(time, DT) >= '11:00:00'
			and convert(time, DT) <= '11:30:00'
		
	-- select the strong stocks into temp table #strongStockTable
	IF OBJECT_ID('tempdb..##strongStockTable','U') IS NOT NULL DROP TABLE ##strongStockTable
	select #curTable.S, #curTable.N, 
		 #curTable.DT DT1, #curTable.Ordi Ordi1, #curTable.P P1, #curTable.R R1,
		 #buyTable.DT DT2, #buyTable.Ordi Ordi2, #buyTable.P P2, #buyTable.R R2 
		 into ##strongStockTable
		 from #curTable inner join #buyTable 
		 on #curTable.S = #buyTable.S
		 order by #curTable.S, DT2
	
	-- show the strong stocks in table
	select * from ##strongStockTable	
	select top 1 * from ##strongStockTable
	
	-- for each symbol
	declare symbolCursor scroll cursor for select distinct S from ##strongStockTable
	open symbolCursor
	declare @curSymbol int
	fetch next from symbolCursor into @curSymbol
	while @@fetch_status=0 
	begin
			print @curSymbol
			
			
			
			--exec proc_zjlx @curSymbol, @nextDate, @ordiMin, @ordiMax, @rLimit, @sellTime
			
				--------------------------------------------------------------------------------
				
				declare @buyDate  nchar(128)
				set @buyDate = @nextDate
				-- cursor to the unique date after buy date	
				declare buyCursor cursor for select distinct convert(date, DT) from [1DAY] 
					where convert(Date, DT) > @buyDate	order by   convert(date, DT)
					
				-- iter over the dates to find the sell price
				open buyCursor
				declare @sellDate nchar(128)
				
				declare @tempHoldDays int
				set @tempHoldDays = @holdDays
				while @tempHoldDays > 0
				begin 
					fetch next from buyCursor into @sellDate 
					set @tempHoldDays = @tempHoldDays - 1
				end 
			
				while @@fetch_status=0 
				begin
					print 'Sell One:'
					print convert(date, @sellDate)
					-- drop temp table if exist
					IF OBJECT_ID('tempdb..#sellTable','U') IS NOT NULL DROP TABLE #sellTable
					
					-- select the stock to be sail on the @sellDate and  @sellTime
					select top 1 DT, Ordi, S, P, R into #sellTable from [1DAY] 
						where  convert(date, DT) = @sellDate and convert(time, DT) <= @sellTime and S = @curSymbol
						order by DT desc
					
					-- check the stock exist
					declare @sellCount	int
					select @sellCount = count(*) from #sellTable 	
					
					if @sellCount <> 0 
					begin
						insert into BS
						select top 1 ##strongStockTable.*, #sellTable.DT DT3, #sellTable.Ordi Ordi3, #sellTable.P P3, #sellTable.R R3								
						from ##strongStockTable inner join #sellTable
						on ##strongStockTable.S = #sellTable.S  
						order by ##strongStockTable.DT2 desc
						
						-- stop if got such a stock 
						break
					end 
							   		
					
					-- if there is no such a stock select the last one of the day.
					begin
						IF OBJECT_ID('tempdb..#sellTable2','U') IS NOT NULL DROP TABLE #sellTable2
						select top 1 DT, Ordi, S, P, R into #sellTable2  from [1DAY] 
							where  convert(date, DT) = @sellDate and S = @curSymbol
							order by DT desc 
					end
					
					select @sellCount = count(*) from #sellTable2
					if @sellCount <> 0 
					begin
						insert into BS
						select ##strongStockTable.*, #sellTable2.DT DT3, #sellTable2.Ordi Orid3, #sellTable2.P P3, #sellTable2.R R3
						from ##strongStockTable inner join #sellTable2
						on ##strongStockTable.S = #sellTable2.S		
						-- stop if got such a stock 
						break
					end 	
									
					-- update the curSellDate for next loop					
					set @tempHoldDays = @holdDays
					while @tempHoldDays > 0
					begin 
						fetch next from buyCursor into @sellDate 
						set @tempHoldDays = @tempHoldDays - 1
					end 

				end 

				close buyCursor
				deallocate buyCursor				
			
			
			
			
			
			
			
			
			
			
			fetch next from symbolCursor into @curSymbol  
	end
	close symbolCursor
	deallocate symbolCursor	-- end for each	 symbol
		   		
	
	--reset @@fetch_status, it is affected by inner cursor
	declare @notused nchar(128)
	fetch prior from dateCursor into @nextDate
	fetch next from dateCursor into @nextDate
	
	set @curDate = @nextDate
end 

close dateCursor
deallocate dateCursor


