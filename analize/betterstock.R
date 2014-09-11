
# install.packages("RODBC")
library(RODBC)

conn <-odbcConnect("Dfcf", uid="sa", pwd="Health123", case="tolower")
datafrm<- sqlQuery(myconn,"select S, O, H, L, P from GGPM")
tail(datafrm)

plot(datafrm$P)

