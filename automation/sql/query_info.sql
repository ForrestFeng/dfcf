/****** Script for SelectTopNRows command from SSMS  ******/
 IF OBJECT_ID('tempdb..#BSTemp','U') IS NOT NULL DROP TABLE #BSTemp

SELECT [S]
      ,[N]
      ,[DT1]
      ,[Ordi1]
      ,[P1]
      ,[R1]
      ,[DT2]
      ,[Ordi2]
      ,[P2]
      ,[R2]
      ,[DT3]
      ,[Ordi3]
      ,[P3]
      ,[R3]
      ,(P3-P2) E
      ,(P3-P2)/P2 EdP
      ,(P3-P3*R3/100) O3			 
      ,((P3+P3*R3/100)-P2) O3E 
  into #BSTemp
  FROM [Dfcf].[dbo].[BS]	   where P1 <>0 and P2 <> 0 and P3 <>0	 order by EdP	
  
  select avg(Edp) EdpAvg	  from #BSTemp
  
  select * from #BSTemp
  
  