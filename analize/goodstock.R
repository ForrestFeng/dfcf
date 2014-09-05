# 1. read.table to rawdata
# 2. update rawdata datetime to POSIXct(add Num col) as mydata
# 3. def function to accept mydata to get stocks that ordinal rise quickly for given time frame, 
# and subset the mydata with filtered stocks with another time frame and retrun it
# 4. def function to show the price and ordinal for a given time frame.

DT_FORMAT = "%Y-%m-%d %H:%M:%S"
DATEFMT = "%Y-%m-%d"

# cols = ['date',
#         'time',
#         'datetime',
#         'ordinal',
#         'symbol',
#         'name',
#         'price',
#         #rise percentage
#         'risepct',
#         'leadm',
#         'leadpct',
#         'superm',
#         'superpct',
#         'bigm',
#         'bigpct',
#         'middlem',
#         'middlepct',
#         'smallm',
#         'smallpct']

get_data <-function(csvfile){
  #
  rawdata <- read.table(csvfile,sep=',', header=TRUE, 
                        colClasses = c(date="NULL" 
                                       ,time="NULL" 
                                       ,datetime="POSIXct" 
                                       ,ordinal="integer"  
                                       ,symbol="integer"  
                                       ,name="character" 
                                       ,price="numeric" 
                                       ,risepct="numeric" 
                                       ,leadm="NULL"
                                       ,leadpct="NULL"
                                       ,superm="NULL"
                                       ,superpct="NULL"
                                       ,bigm="NULL"
                                       ,bigpct="NULL"
                                       ,middlem="NULL"
                                       ,middlepct="NULL"
                                       ,smallm="NULL"
                                       ,smallpct="NULL"
                                       ))

  rawdata
}


subset_data <-function(mydata, start_time, end_time, cols=c()){
  if( length(cols) > 0)  subset(mydata, mydata$datetime <= end_time & mydata$datetime >= start_time, select = cols)
  else subset(mydata, mydata$datetime <= end_time & mydata$datetime >= start_time)
}


topn_symbols <- function(mydata, start_ordinal, end_ordinal){
  # aggregate by the symbol
  mydata$symbol.f <- factor(mydata$symbol)
  if( nrow(mydata) < 1){
    return(c())
  }
  aggregated <- aggregate(mydata[c("ordinal","price")], mydata["symbol.f"], mean)
  topn <- subset(aggregated, aggregated$ordinal >= start_ordinal & aggregated$ordinal <= end_ordinal)
  return(unique(topn$symbol))
}

strong_stocks <- function(mydata, ord_start_date, ord_end_date, trace_end_date, start_ordinal, end_ordinal, buy_time="00:00:00", sell_time="00:00:00"){
  oneday = as.difftime("24:00:00")
  zeroday = as.difftime("00:00:00")
  
  # get the data for the time window we are intreseted in
  trace_data <- subset_data(mydata, ord_start_date, trace_end_date + oneday)
  print(paste("--1", Sys.time(), "-begin strong_stocks windowdays/totaldays:", nrow(trace_data), "/", nrow(mydata)))
  
  # from the raw time window select the ordinal check window we care
  ord_end_date_time <- ord_end_date + oneday
  if(as.difftime(buy_time) != zeroday){
    ord_end_date_time <- ord_end_date + as.difftime(buy_time)
  }
  temdata <- subset_data(trace_data, ord_start_date, ord_end_date_time) # 12 s   
  symbols <- topn_symbols(temdata,start_ordinal,end_ordinal) 
  print(paste("--2", Sys.time(), "-symbols count:", length(symbols)))
  stocks = list()
 
  for ( mysymbol in symbols){ # 43 s
    #mysymbol <- symbol_list[1]    
    one_stock_data <- subset(trace_data, symbol==mysymbol)
    stocks[[as.character(mysymbol)]] = one_stock_data
  }  
  print(paste("--3", Sys.time(), "-complete strong_stocks"))
  return(stocks)
}

the_other_day <- function(){
  
}

show_ordian_price <- function(stock){  
  stock$datetime.f <- factor(strftime(stock$datetime, DATEFMT))
  class(stock[5]) #"data.frame"
  class(stock$price) # "numeric"
  
  #Error in aggregate.data.frame(as.data.frame(x), ...) : 'by'....
  #aggregate(stock$price, stock$datetime.f, mean) 
  
  # aggregate must use dateframe instead of seprated vector
  # now aggregate the oridnal(3) and price(5) by datetime.f
  names(stock)
  aggregated <- aggregate(stock[c(3,5)], stock[6], mean)
  print(aggregated)
  
  # plot boxed price for each day
  plot(stock$datetime.f, stock$price)
  # plot boxed ordianl for each day
  plot(stock$datetime.f, stock$ordinal)
  # hot wo merge the box and oridnal boxes in the same plot?
  
}

gstock = list()
# check price trend of in the following n days for all strong stocks  
# buy_time, sell_time the time point to buy or sell. eg "11:25:00" 
# this time will be converted to a difftime with as.difftime(c("11:25:00", "14:25:00"), units="hours")
# default value for both buy_time and sell_time are "00:00:00", which means buy ans sell with close price
ndays_mean_price_and_ordinal <- function(sstocks, start_date, ndays, buy_time="00:00:00", sell_time="00:00:00"){    
  ret <- list()
  
  oneday = as.difftime("24:00:00")
  zeroday = as.difftime("00:00:00")
        
  
  for(syb in names(sstocks) ){
    # data frame of one stock from strong stocks list
    stock <- sstocks[[syb]]
    print(syb)
    # unique dates this stock be observed
    unique_dates <- unique(strptime(stock$datetime, DATEFMT))
    unique_dates <- unique_dates[unique_dates >= start_date][1:ndays]
    dateslen = length(unique_dates)    
    #print ( unique_dates ) 
    print(unique_dates)

    # capture symbol and date to returned data frame
    ret[["symbol"]] = c(ret[["symbol"]], syb )
    ret[["date"]] = c(ret[["date"]], strftime(start_date, "%m-%d"))
    ret[["buytime"]] = c(ret[["buytime"]], buy_time)
    ret[["selltime"]] = c(ret[["selltime"]], sell_time)
    
    # add mean(ordianl) and mean(price) of each day to the returned data frame for this stock
    for( i in c(1: dateslen ) ) {
      sdate = unique_dates[i]
      edate = unique_dates[i] + oneday
           
      tstock <- subset(stock, datetime >= sdate & datetime <=  edate)
      lenrows = nrow(tstock)
      #print(paste("----------------------------", head(tstock)))   
      ret[[paste("ordmean",(i), sep=".")]] = c(  ret[[paste("ordmean",(i), sep=".")]] , mean(tstock$ordinal) )       
      ret[[paste("prcmean",(i), sep=".")]] = c(  ret[[paste("prcmean",(i), sep=".")]] , mean(tstock$price)   )   

      
      if(as.difftime(buy_time) != zeroday){
        tstock <- subset(stock, datetime >= sdate & datetime <=  (unique_dates[i] + as.difftime(buy_time)))  
        lenrows = nrow(tstock)    
      }  
      ret[[paste("buyprc",(i), sep=".")]]     = c(  ret[[paste("buyprc",(i), sep=".")]] ,     tstock$price[lenrows] )  
      ret[[paste("buyordmean",(i), sep=".")]] = c(  ret[[paste("buyordmean",(i), sep=".")]] , mean(tstock$ordinal)  ) 
    

      if(as.difftime(sell_time) != zeroday){
        tstock <- subset(stock, datetime >= sdate & datetime <=  (unique_dates[i] + as.difftime(sell_time)))  
        lenrows = nrow(tstock)
      }           
      ret[[paste("sellprc",(i), sep=".")]]     = c(  ret[[paste("sellprc",(i), sep=".")]] ,     tstock$price[lenrows] ) 
      ret[[paste("sellordmean",(i), sep=".")]] = c(  ret[[paste("sellordmean",(i), sep=".")]] , mean(tstock$ordinal)  )
    
    }    
  }  
  return(data.frame(ret))
}

# show you the profit of  day 3 and day 2 orver when buying on day 1. 
# day 0 is for watching not buy 
profit_3_1_2_1_test <- function(sstocks, ord_start_date, testing_days, buy_time="00:00:00", sell_time="00:00:00"){  
  result <- list()  
  # pick one stock and show it
  if(length(sstocks) < 1){
    print("No such stocks found, please change your parameters") 
    return(data.frame(result))
  } 
  #stock <- sstocks[[1]]
  #show_ordian_price(stock)
  

  
  # get n days mean data for all strong stocks from  ord_start_date
  ret <- ndays_mean_price_and_ordinal(sstocks, ord_start_date, testing_days, buy_time, sell_time)

  # remove bad rows with price of 0
  ret <- subset(ret, prcmean.1 >0 & prcmean.2 > 0 & prcmean.3 > 0 & prcmean.4 >0)

  # how much strong stocks were choosen to buy
  poolsz <- nrow(ret)    
  
  # how many stocks is profitable if buy with mean.1 and sell with mean.2 or mean.3
  rise_2_1 <- sum(ret$prcmean.2 > ret$prcmean.1)
  rise_3_1 <- sum(ret$prcmean.3 > ret$prcmean.1)
  rise_4_1 <- sum(ret$prcmean.4 > ret$prcmean.1)
  rise_3_2 <- sum(ret$prcmean.3 > ret$prcmean.2)
  rise_4_2 <- sum(ret$prcmean.4 > ret$prcmean.2)
  
  # buy every stock of price mean.1 with 1 unit money and sell it on price mean.2 or mean.3
  # we can calculate our total profit for all the stocks:
  pft_2_1 <- sum(ret$prcmean.2 / ret$prcmean.1 - 1)
  pft_3_1 <- sum(ret$prcmean.3 / ret$prcmean.1 - 1)
  pft_4_1 <- sum(ret$prcmean.4 / ret$prcmean.1 - 1)
  pft_3_2 <- sum(ret$prcmean.3 / ret$prcmean.2 - 1)
  pft_4_2 <- sum(ret$prcmean.4 / ret$prcmean.2 - 1)
  
  # the earning ratio will be total profit divided by total money spent
  pct_2_1 <- pft_2_1 / poolsz
  pct_3_1 <- pft_3_1 / poolsz
  pct_4_1 <- pft_4_1 / poolsz
  pct_3_2 <- pft_3_2 / poolsz
  pct_4_2 <- pft_4_2 / poolsz
  
  # put summarision to a data frame
  result[["date"]] = c(result[["date"]], strftime(ord_start_date, "%m-%d"))
  result[["days"]] = c(result[["days"]], testing_days)
  result[["poolsz"]] = c(result[["poolsz"]], poolsz)  
  
  result[["upcnt2.1"]] = c(result[["upcnt2.1"]], rise_2_1)
  result[["upcnt3.1"]] = c(result[["upcnt3.1"]], rise_3_1)  
  result[["upcnt4.1"]] = c(result[["upcnt4.1"]], rise_4_1) 
  result[["upcnt3.2"]] = c(result[["upcnt3.2"]], rise_3_2)
  result[["upcnt4.2"]] = c(result[["upcnt4.2"]], rise_4_2)  
  
  result[["pft2.1"]] = c(result[["pft2.1"]], pft_2_1)
  result[["pft3.1"]] = c(result[["pft3.1"]], pft_3_1)
  result[["pft4.1"]] = c(result[["pft4.1"]], pft_4_1)
  result[["pft3.2"]] = c(result[["pft3.2"]], pft_3_2)
  result[["pft4.2"]] = c(result[["pft4.2"]], pft_4_2)
  
  result[["pct2.1"]] = c(result[["pct2.1"]], pct_2_1)
  result[["pct3.1"]] = c(result[["pct3.1"]], pct_3_1) 
  result[["pct4.1"]] = c(result[["pct4.1"]], pct_4_1) 
  result[["pct3.2"]] = c(result[["pct3.2"]], pct_3_2)
  result[["pct4.2"]] = c(result[["pct4.2"]], pct_4_2) 
 
  return(list(agg=data.frame(result), price=ret))
}


profit_full_test <- function(mydata, ord_start_date, ord_end_date, trace_end_date, testing_days, topn_a=100, topn_b=200, 
                             buy_time="00:00:00", sell_time="00:00:00"){  
  # select strong stocks, a strong stock have at least one ordinal inbetween topn_a and topn_b in the 
  # given ordinal window.  
  sstocks <- strong_stocks(mydata, ord_start_date, ord_end_date, trace_end_date, topn_a, topn_b, buy_time, sell_time) #
  summary(sstocks)
  
  ret <- profit_3_1_2_1_test(sstocks, ord_start_date, testing_days, buy_time, sell_time)
  ret
}

# simulate the real trading. on trading dates 
# to buy and sell at specific time point
tradesim <- function(trading_dates, buy_time, sell_time){
  sstocks <- strong_stocks(mydata, ord_start_date, ord_end_date, trace_end_date, topn_a, topn_b) #
  summary(sstocks)
}

# read raw data
##################################################
print(paste("--0", Sys.time()))
csvfile = 'D:\\home\\projects\\dfcfpy-fast-version\\data\\generated\\crushed.1Day.zjlx.csv'
mydata <- get_data(csvfile) #20s
# remove all the data that not on market for the trading day
#mydata <- mydata[mydata$price!= 0,] 
print(paste("--1", Sys.time()))

# specific date range data
##################################################
if(0){
  start_time <- strptime("2014-08-04",DATEFMT)
  end_time   <- strptime("2020-01-01",DATEFMT) # read all the data
  #cols <- c("datetime", "symbol", "ordinal","risepct", "price")
  mydata <- subset_data(mydata, start_time, end_time)  #16s
  summary(mydata)
  print(paste("--2", Sys.time()))
}

# parameters
##################################################
topn_a      <- 100
topn_b      <- 200
dates <- c("2014-08-07",
           "2014-08-08","2014-08-12","2014-08-13","2014-08-14","2014-08-15",
           "2014-08-18","2014-08-19","2014-08-20","2014-08-21","2014-08-22",
           "2014-08-25", "2014-08-26")

# dates <- c(
#            "2014-08-18","2014-08-19","2014-08-20","2014-08-21","2014-08-22",
#            "2014-08-25", "2014-08-26")
dates <- strptime(dates, DATEFMT)
dateslen = length(dates)
testing_days = 4           #total testing days in clude ordinal test window
ordinal_window_days = 2    #ordinal testing window
buy_time="14:30:00"
sell_time="14:30:00"
buy_time="00:00:00"
sell_time="00:00:00"

# main calc
##################################################
agg = list()
prc = list() #price
sstocks = list()
for( i in 1: (dateslen - testing_days) ){
  ord_start_date <- dates[i]
  ord_end_date   <- dates[i + ordinal_window_days - 1]
  trace_end_date     <- dates[i + testing_days -1  ] # including the end date.
  
  info <- paste(ord_start_date, "-> ",  ord_end_date)
  print(info)
  sstocks <- strong_stocks(mydata, ord_start_date, ord_end_date, trace_end_date, topn_a, topn_b, buy_time, sell_time)
  
  retdata <- profit_full_test(mydata, ord_start_date, ord_end_date, trace_end_date, testing_days, topn_a, topn_b, buy_time, sell_time)
  agg <- rbind(agg, retdata[["agg"]])
  prc <- rbind(prc, retdata[["price"]])
  tail(agg)
  tail(prc)
}

# the net win ratio (with 5/1000 fee removed)
feepct = 0.005
hist(agg$pct3.2 - feepct)
mean(agg$pct3.2 - feepct)
hist(agg$pct4.2 - feepct)
mean(agg$pct4.2 - feepct)






















































# if we buy stock on day 1 and sell it day 3, we can reuse the money on the third day. So totocally 
# our principal sum is 2 units to start the game.
# one unit for day 1 and 
# another one unit for day 2
# day 3, reuse the unit spent on day 1
# day 4, reuse the unit spent on day 2
# after that each day we have 2 unit in market 
# and each unit win about 1% the other day...
# for the 76 rule, after 76 * 2 = 130 trading days each unit becomes 2 unit.
# that is to say after about one yeay we can double our money.


#    111 112 113 114 115 116  . . .
# 1   -   -   -   -   -   -
# 2   -   B   -   -   -   -
# 3   -   -   B   -   -   -
# 4   -   -   -  S/B  -   -
# 5   -   -   -   -  S/B  -
# 6   -   -   -   -   -  S/B
# .
# .
