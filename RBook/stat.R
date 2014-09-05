library(ggplot2)

csvfile = 'D:\\home\\projects\\dfcfpy-fast-version\\data\\generated\\crushed.1Day.zjlx.csv'
mydata <- read.table(csvfile,sep=',', header=TRUE)

# this section will select stocks of top(x, y) and calculate the cor(ordinal, risepct) and push to 
# mycor vector. At last it will print the mycor and show the mycor summary.
calculate_and_plot_cor <- function(){
  # only use subset data
  mydata$datetime <- strptime(mydata$datetime,"%Y-%m-%d %H:%M:%S")
  mydata$num <- seq(1, dim(mydata)[1])
  mydata <- subset(mydata,select = c(num, datetime, symbol, ordinal, risepct, price))
  
  topn_range <- c(10, 20)
  topn <- subset(mydata, ordinal <= topn_range[2])
  topn <- subset(topn, ordinal >= topn_range[1])
  
  symbol_list <- topn$symbol
  
  # get all cors for topn symbols
  mycors <- c()
  for ( mysymbol in unique(symbol_list)){
    #mysymbol <- symbol_list[1]
    
    one_stock_data <- subset(mydata, symbol==mysymbol)
    
    mycor <- cor(one_stock_data[,c('ordinal','price', 'risepct')])
   
    orinal_price_cor <- mycor[1,3]
    mycors <- c(mycors, orinal_price_cor)
  }  
  summary(mycors)
  hist(mycors)
  mycord <- density(mycors, na.rm = TRUE)
  plot(mycord)
}

lean_to_plot_pairs <- function(){
  symbol_list = c(603000,600633)
  
  for( symbol in symbol_list){    
    mystock <- mydata[mydata$symbol==symbol,]
    mystock$datetime <- strptime(mystock$datetime,"%Y-%m-%d %H:%M:%S")
    mystock$num <- seq(1, dim(mystock)[1])
    
    # plot the price,ordianl assign to colour, shot ordinal as text annotate
    #mytitle <- paste( as.character(mystock$name[1]), as.character(mystock$symbol[1] ) )
    #ggplot(data=mystock, aes(x=num, y=price, colour = ordinal)) + geom_text(aes(y=price+0.01, label=ordinal),size = 4)
    #plot(mystock$num, mystock$price) 
    
    # pairs plot
    mystock_subset <- subset(mystock,select = c(num, ordinal, risepct, price))
    
    ## put histograms on the diagonal
    panel.hist <- function(x, ...)
    {
      usr <- par("usr"); on.exit(par(usr))
      par(usr = c(usr[1:2], 0, 1.5) )
      h <- hist(x, plot = FALSE)
      breaks <- h$breaks; nB <- length(breaks)
      y <- h$counts; y <- y/max(y)
      rect(breaks[-nB], 0, breaks[-1], y, col = "cyan", ...)
    }
    
    ## put (absolute) correlations on the upper panels,
    ## with size proportional to the correlations.
    panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
    {
      usr <- par("usr"); on.exit(par(usr))
      par(usr = c(0, 1, 0, 1))
      r <- abs(cor(x, y))
      txt <- format(c(r, 0.123456789), digits = digits)[1]
      txt <- paste0(prefix, txt)
      if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
      text(0.5, 0.5, txt, cex = cex.cor * r)
    }
    # plot pairs
    if( 1 ){
      pairs(mystock_subset, 
            main = symbol,
            upper.panel = panel.cor,
            diag.panel = panel.hist,
            lower.panel = panel.smooth)
    }    
  }
}

# calculate the cor value for in reald data against the ref data
calculate_cor_against_refdata <- function(ref_data, real_data){
  ref_sz <- length(ref_data)
  real_sz <- length(real_data)
  
  if(ref_sz < 1 || real_sz < ref_sz)
    return;
    
  last_idx = real_sz - ref_sz + 1
  for ( i in c(1:last_idx)){
    partial <- real_data[i: (i + ref_sz - 1)] # must use () 

    mycor <- cor(ref_data, partial)
    print(mycor)
  }  
}

# test is the in vector of a drop trend
drop_test <- function(in_vector){  
  sz <- length(in_vector)   
  #print(in_vector[1:8])
  idx <-   c(1,  2, 3,  5,  8)#, 13)#, 21)
  upper <- c(20,40,60,100,160)#,260)#,420)  
  
  FCNT <- length(idx)    
  true_cnt <- sum(in_vector[idx] < upper)  
  if(true_cnt > FCNT - 2){
    TRUE
  }else{
    FALSE
  }  
}

# filter the in stock data print its data if its ordinal pass the drop test
zjlx_ordinal_filter <- function(one_stock_data){
  ordinal_new_on_first <- rev( one_stock_data$ordinal )
  price_new_on_first <- rev( one_stock_data$price)
  datetime_new_on_first <- rev(one_stock_data$datetime)
  symbol_new_on_first <- rev(one_stock_data$symbo)
  mysymbol <- one_stock_data$symbol[1]
  mydatetime <- one_stock_data$datetime[1]
  

  if( drop_test(ordinal_new_on_first) ){    
    print(mysymbol)
    idx <- c(1:30)
    ordina_price_data <- data.frame(
      symbol = symbol_new_on_first[idx],
      datetime = datetime_new_on_first[idx],
      ordinal=ordinal_new_on_first[idx], 
      price = price_new_on_first[idx]      
      ) 
    #write.table(ordina_price_data, cat(as.character(mydatetime), mysymbol), sep=',', row.names=FALSE)
    #print(ordina_price_data)   
    ordina_price_data
  }else{
    NA
  }
}

# main function for filter zjlx data with passed in filter function
filter_zjlx_ordinal_pass_drop_test <- function(filter_function){
  # only use subset data of mydata.
  mydata$datetime <- strptime(mydata$datetime,"%Y-%m-%d %H:%M:%S")
  mydata$num <- seq(1, dim(mydata)[1])
  mydata <- subset(mydata,select = c(num, datetime, symbol, ordinal, risepct, price))
  
  topn_range <- c(0, 20)
  topn <- subset(mydata, ordinal <= topn_range[2])
  topn <- subset(topn, ordinal >= topn_range[1])  
  symbol_list <- topn$symbol
  
  for ( mysymbol in unique(symbol_list)){
    #mysymbol <- symbol_list[1]    
    one_stock_data <- subset(mydata, symbol==mysymbol)
    filter_function(one_stock_data)    
  }
}

# calling functions
filter_zjlx_ordinal_pass_drop_test(zjlx_ordinal_filter)






