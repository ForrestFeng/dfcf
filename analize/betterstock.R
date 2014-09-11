
# install.packages("RODBC")
library(RODBC)

conn <-odbcConnect("Dfcf", uid="sa", pwd="Health123", case="tolower")
datafrm<- sqlQuery(conn,"select DT, S, O, H, L, P from GGPM where S = 300232 order by DT")
tail(datafrm)

plot(datafrm$DT, datafrm$P, type="l")

