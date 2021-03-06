USE Dfcf

-- Select records of specific date with Ordi in range [] and time in range []
SELECT [DT],[Ordi],[S],[P],[R] FROM [Dfcf].[dbo].[1DAY] 
  WHERE  DT > '2014-08-13' AND Ordi > 0 AND Ordi < 20 AND R < 9 AND DatePart(Hour, DT) >= 13 AND DatePart(Hour, DT) <= 14
  ORDER BY DT


-- Get the date for the selected data from the result above
SELECT DISTINCT CONVERT(date, DT) FROM (
	SELECT [DT],[Ordi],[S],[P],[R] FROM [Dfcf].[dbo].[1DAY] 
	  WHERE  DT > '2014-08-13' AND Ordi > 0 AND Ordi < 20 AND R < 9 AND DatePart(Hour, DT) >= 13 AND DatePart(Hour, DT) <= 14
	  )T
  ORDER BY CONVERT(date, DT)

  

-- Summary the record count for each day
SELECT COUNT(*), CONVERT(date, DT)COUNT_OF_REC FROM [1DAY] GROUP BY CONVERT(date, DT) ORDER BY CONVERT(date, DT)


