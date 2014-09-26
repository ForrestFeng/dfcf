
# install.packages("RODBC")
library(RODBC)

#
#plot(datafrm$DT, datafrm$P, type="l")

HOUR_START = 9
HOUR_END = 13
conn <-odbcConnect("Dfcf", uid="sa", pwd="Health123", case="tolower")

# select data for specific time for each day with Ordi in specific range
dfmQueryStr <- paste("SELECT [DT],[Ordi],[S],[P],[R] FROM [Dfcf].[dbo].[1DAY] 
  WHERE  DT > '2014-08-13' AND Ordi > 0 AND Ordi < 20 AND R < 9 AND DatePart(Hour, DT) >= ", HOUR_START,  " AND DatePart(Hour, DT) <= ", HOUR_END, " 
  ORDER BY DT")

dfrm <- sqlQuery(conn, dfmQueryStr)
tail(dfrm)

# select the unite date coverd by datafrm
unique_dates <- sqlQuery(conn, 
"SELECT DISTINCT CONVERT(date, DT) DT FROM [Dfcf].[dbo].[1DAY] 
    WHERE  DT > '2014-08-13' 
	  ORDER BY CONVERT(date, DT)")
tail(unique_dates)
date_range <- as.POSIXlt(unique_dates$DT)


###################################
all_day = list()
for ( i in 1:(length(date_range)) ) {  
  if( i < length(date_range)){
    all_day[[i]] =  subset(dfrm, DT > date_range[i] & DT < date_range[i+1])  
  }
  else{
    all_day[[i]] =  subset(dfrm, DT > date_range[i])
  }  
}


#######################################

options(digits = 2) 
for ( i in 2:(length(all_day) - 2) ) {  
  # current day
    curday <- all_day[[i]]
    preday <- all_day[[i-1]]
    
    inter_stocks <- intersect(preday$S, curday$S)
    print(paste('-----------------', curday[1,'DT']))
    print(inter_stocks)
    
    
    for( symbol in inter_stocks[1:1]){
      
      cur_stock <- subset(curday, S == symbol)      
      lastrow <- length(cur_stock[,1])
      print(cur_stock[lastrow,])
      
      sell_stock <- subset(all_day[[i+2]], S == symbol)      
      #print(sell_stock)
      lastrow2 <- length(sell_stock[,1])
      print(sell_stock[lastrow2,])
    }    
    
}
