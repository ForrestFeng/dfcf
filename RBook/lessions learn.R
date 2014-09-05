# book Data Manipulation with R.pdf

mylist = list(a=c(1,2,3),b=c("cat","dog","duck"),
              d=factor("a","b","a"))
sapply(mylist,mode)
y = c(1,2,"cat",3) # character win
z = c(5,TRUE,3,7)  # numeric win
mode(z)
all = c(x,y,z)
all # all is of mode character

# Names can be given like this
x = c(one=1,two=2,three=3)

# or use names function
x = c(1,2,3)
names(x) = c('one','two','three')
names(x)[1:2] = c('uno','dos')
x

# R will recycle the values of the shorter vector in order to make the lengths compatible
nums = 1:10
nums + 1

nums = 1:10 
nums + c(1,2)

nums = 1:10
nums + c(1,2,3) # worning, onger object length is not a multiple 

# matrix is stored as vector with dimentions of 2. 
#all of the objects of an array must be of the same mode, so does matrix

# the matrix function converts a vector to a matrix, 
# atrices are internally stored by columns
rmat = matrix(rnorm(15),5,3,
              dimnames=list(NULL,c('A','B','C')))
dimnames(rmat) = list(NULL,c('A','B','C'))


#Lists provide a way to store a variety of objects of possibly varying modes
#in a single R object. list element length need not be the same.
mylist = list(c(1,4,6),"dog",3,"cat",TRUE,c(9,10,11))
sapply(mylist,mode)


#Like other objects in R, list elements can be named, when create or by names function
mylist = list(first=c(1,3,5),second=c('one','three','five'),
              third='end')
names(mylist) = c('first','second','third')

#
# data frame
# A data frame is a list with the restriction that each element of the list (the variables)
# must be of the same length as every other element of the list



# For simple cases such as vectors, matrices, and data frames, it's usually
# straightforward to determine what an object in R contains; examining the
# class and mode of the object, along with its length or dim attribute, should
# be sufficient to allow you to work effectively with the object

# summary function will provide the names, lengths, classes, and modes of
mylist = list(a=c(1,2,3),b=c("cat","dog","duck"),
               d=factor("a","b","a"))
summary(mylist)

# nested lsit, summary provides useful information, but only looks at top-level elements
nestlist = list(a=list(matrix(rnorm(10),5,2),val=3),
                b=list(sample(letters,10),values=runif(5)),
                c=list(list(1:10,1:20),list(1:5,1:10)))
summary(nestlist)

# str provides details about the nature of all the components of the object
# indentation provides visual cues to the structure of the object:
str(nestlist)

# 1.5 Conversion of Objects

# "as." changes the way an object in R behaves
nums <- as.numeric( c("1", "2", "3"))
nums

# table function
# will return a vector of integer counts representing how many times each unique value in an object appears
# The vector it returns is named, based on the unique values encountered.
nums = c(12,10,8,12,10,12,8,10,12,8)
tt = table(nums)
tt
names(tt)

sum(as.numeric(names(tt)) * tt)

# as.list() vs list() as. 
# as. forms for many types of objects behave very differently than the function which bears the type's name
x = c(1,2,3,4,5)
list(x) # length 1
as.list(x) # length 5 same as x

# 1.7 Working with Missing Values
# NA, Inf, NaN
# The value NA, without quotes, represents a missing value
# is.na test missing value, is.nan test not a number 
is.numeric(Inf) # TRUE
is.na( c(NA,2, 8) ) # TRUE FALSE FALSE
is.nan( c(NaN,2, 8) ) # TRUE FALSE FALSE

x[!is.na(x)] # only none-missing values

# functions like mean, var, sum, min, max accept na.rm= arg
x = c(1,2,3,4,NA,5)
sum(x, na.rm=TRUE)

# 2 Reading and Writing Data
names = scan(what="")
names













#6
#Subscripting


#6.2 Numeric Subscripts
#6.3 Character Subscripts
#6.4 Logical Subscripts
nums = c(12,9,8,14,7,16,3,2,9)
nums > 10
nums[nums>10]
which(nums>10)


#6.5 Subscripting Matrices and Arrays
x = matrix(1:12,4,3)
x[,1]
x[,c(3,1)]
x[2,]
x[10] # x treated as vector

stack.x.a = stack.x[order(stack.x[,'Air.Flow']),]
stack.x.a = stack.x[order(stack.x[,'Air.Flow'], decreasing=TRUE), ]
head(stack.x.a)

#6.5 Subscripting Matrices and Arrays 79
sortframe = function(df,...)df[do.call(order,list(...)),]
with(iris,sortframe(iris,Sepal.Length,Sepal.Width))

#reversing the order of rows or columns
riris = iris[rev(1:nrow(iris)),]
head(riris)

#By default, subscripting operations reduce the dimensions of an array
#whenever possible. Extracted part can be retained with the drop=FALSE argument, 
#which is passed along with the subscripts of the array
x = matrix(1:12,4,3)
x[,1]
x[,1,drop=FALSE] #drop=FALSE is considered an argument to the subscripting operation

x[,1] < 3
x[x[,1] < 3,]

mat = matrix(scan(),ncol=3,byrow=TRUE)
mat = matrix(c(1,1,12,1,2,7,2,1,9,2,2,16,3,1,12,3,2,15), ncol=3, byrow=TRUE)
mat
# first two columns describe a matrix with three rows and two columns
mat[,1:2]
newmat = matrix(NA,3,2)
newmat[mat[,1:2]] = mat[,3]

#6.6 Specialized Functions for Matrices
method1 = c(1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4)
method2 = c(1,2,2,3,2,2,1,3,3,3,2,4,1,4,4,3)
tt = table(method1,method2)
tt
class(tt)
summary(tt) #what's the difference between 
offd = row(tt) != col(tt)
tt[offd]
sum(tt[offd])
#The R functions lower.tri and upper.tri use this technique to return a
#logical matrix useful in extracting the lower or upper triangular elements of
#a matrix.

#6.7 Lists 

#Lists are the most general way to store a collection of objects in R
simple = list(a=c('fred','sam','harry'),b=c(24,17,19,22))
class(simple)
mode(simple)

#Although it looks as if simple[2] represents the vector, it's actually a list
#containing the vector; operations that would work on the vector will fail on this list:
simple[2]
mode(simple[2]) #"list" 
mean(simple[2])

mode(simple$b)
mean(simple$b)

#Double brackets operator:
#It is not restricted to respect the mode of the object they are
#subscripting; instead, it will extract the actual element from the list
mean(simple$b)
[1] 20.5
mean(simple[[2]])
[1] 20.5
mean(simple[['b']])
[1] 20.5

# single vs double bracket operator
# single brackets will always return a list containing the selected element(s),
# double brackets will always return the actual contents of selected list element
simple[1]
$a
[1] "fred" "sam" "harry"
simple[[1]]
[1] "fred" "sam" "harry"


#
#6.8 Subscripting Data Frames
dd = data.frame(a=c(5,9,12,15,17,11),b=c(8,NA,12,10,NA,15))
dd[dd$b > 10,]
dd[!is.na(dd$b) & dd$b > 10,] # what's difference of & and &&

#subset function 
## S3 method for class 'data.frame'
# subset(x, subset, select, drop = FALSE, ...)

subset(dd, b>10) #not necessary to use the data frame name

#Unlike most other functions in R, names passed through the
#select= argument can be either quoted or unquoted. 

#To ignore columns, their name or index number can be preceded by a negative sign (-)
some = subset(LifeCycleSavings,sr>10,select=c(pop15,pop75))

life1 = subset(LifeCycleSavings,select=pop15:dpi)
life1 = subset(LifeCycleSavings,select=1:3) # same as above

life2 = subset(LifeCycleSavings,select=c(-pop15,-pop75))
life2 = subset(LifeCycleSavings,select=c(-2,-3))# same as above
life2 = subset(LifeCycleSavings,select=-c(2,3))# same as above


#7 Character Manipulation
#Character values in R can be stored as scalars, vectors, or matrices, or they can be 
#columns of a data frame or elements of a list.
#length function will report the number of character values in
#the object, not the number of characters in each string. 
#use nchar to get char numbes instead. nchar it is vectorized. length is not!

#7.1 Basics of Character Data
state.name
str(state.name)
chr [1:50] "Alabama" "Alaska" "Arizona" ...

mode(state.name)
[1] "character"

length(state.name)
nchar(state.name)

# cat function. 
# it coerces its arguments to character values, then concatenates and displays them
cat(... , file = "", sep = " ", fill = FALSE, labels = NULL,
    append = FALSE)

x = 7
y = 10
cat('x should be greater than y, but x=',x,'and y=',y,'\n')

cat('Long strings can','be displayed over',
      'several lines using','the fill= argument',
      fill=40)
cat('Long strings can','be displayed over',
    'several lines using','the fill= argument',
    fill=20)


# paste func
paste (..., sep = " ", collapse = NULL)

# for multi-args
paste('one',2,'three',4,'five')
paste('one',2,'three',4,'five', sep = '-$')
# for vectors, collapse= argument must be used sep= has no effect 
paste(c('one','two','three','four'),collapse=' ')
paste(c(1,'two','three',4.01),collapse=' ')
# mix vectors and orther args result recycling short args
paste('X',1:5,sep='')
paste(c('X','Y'),1:5,sep='')
#collapse is used, will collapse to *one* string
paste(c('X','Y'),1:5,sep='', collapse="")

paste(c('X','Y'),1:5,'^',c('a','b'),sep='_')
paste(c('X','Y'),1:5,'^',c('a','b'),sep='_',collapse='|')

#
#7.3 Working with Parts of Character Values 89

#Individual characters of character values are not accessible through ordinary subscripting


















#P114

maxcor = function(i, n=10, m=5){
  mat = matrix(rnorm(n*m), n, m)
  corr = cor(mat)
  diag(corr) = NA
  max(corr, na.rm=TRUE)
}

maxcor_even = function(i, n=10, m=5){
  mat = matrix(rnorm(n*m), n, m)
  corr = cor(mat)
  diag(corr) = NA
  
  # what to return depends on input i
  # must return NA if not applicable
  if(i %% 2 == 0){
    max(corr, na.rm=TRUE)
  }
  else{
    NA
  }
}
simple_vec = function(i, n=10, m=5){
  seq(1: n)
}

maxcors = sapply(1:5, simple_vec, n=7)
plot(maxcors)

text = c('R is a free environment for statistical analysis', 
         'It compiles and runs on a variety of platforms', 
         'Visit the R home page for more information') 

result = strsplit(text,' ')
length(result)
sapply(result,length)

head(ChickWeight)
class(ChickWeight)
summary(ChickWeight)
ChickWeight$weight
class(ChickWeight)
sapply(ChickWeight,class)


#
#8.3 Mapping a Function to a Vector or List 109
sapply(ChickWeight,class) == 'numeric'
ChickWeight[,sapply(ChickWeight,class) == 'numeric']

t.test(rnorm(10),rnorm(10))$statistic
tsim = replicate(10000,t.test(rnorm(10),rnorm(10))$statistic)
head(tsim)
class(tsim)
summary(tsim)
quantile(tsim,c(0.5,0.75,0.9,0.95,0.99))

#110
state.x77
head(state.x77)
class(state.x77)
summary(state.x77)
#For matrices, a second argument
#of 1 means "operate on the rows", 
#and 2 means "operate on the columns"
sstate = scale(state.x77,center=apply(state.x77,2,median), 
               scale=apply(state.x77,2,mad))

#This example illustrates another advantage of using apply instead of a loop,
#namely, that apply will use names that are present in the input matrix or
#data frame to properly label the result that it returns
sumfun = function(x)c(n=sum(!is.na(x)),mean=mean(x),sd=sd(x))
x = apply(state.x77,2,sumfun)
t(x)

#111
x = 1:12
apply(matrix(x,ncol=3,byrow=TRUE),1,sum)

rowSums
colSums
rowMeans

USJudgeRatings
head(USJudgeRatings)
class(USJudgeRatings)
summary(USJudgeRatings)
mns = colMeans(USJudgeRatings)

#112 8 Data Aggregation
sweep

USJudgeRatings >= 8
jscore = rowSums(USJudgeRatings >= 8)
head(jscore)

maxes = apply(state.x77,2,max)
swept = sweep(state.x77,2,maxes,"/")
head(swept)

#
#8.5 Mapping a Function Based on Groups 113
meds = apply(state.x77,2,median)
meanmed = function(var,med)mean(var[var>med])
meanmed(state.x77[,1],meds[1])
meanmed(state.x77[,2],meds[2])
sweep(state.x77,2,meds,meanmed)

#By default, mapply will always simplify its results, as in the previous
#case where it consolidated the results in a vector. To override this behavior,
#and return a list with the results of applying the supplied function, use
#the SIMPLIFY=FALSE argument.
mapply
mapply(meanmed,as.data.frame(state.x77),meds)

# 
#8.5 Mapping a Function Based on Groups
#114 8 Data Aggregation

#f
aggregate

iris
head(iris)
class(iris)
summary(iris)
iris[-5] #remove only this col with its col num
iris[5]  #select only this col with its col num
aggregate(iris[-5],iris[5],mean)

# there is a typo not = > should be <-
cweights <- aggregate(ChickWeight$weight,
                       ChickWeight[c('Time','Diet')],mean)
head(cweights)

#Error in aggregate.data.frame(as.data.frame(x), ...) : 
#object 'groups' not found. 
groups <- list(Time=ChickWeight$Time,Diet=ChickWeight$Diet)
cweights <- aggregate(ChickWeight$weight,
                      groups,mean) 

#f
tapply

PlantGrowth
head(PlantGrowth)
class(PlantGrowth)
summary(PlantGrowth)
maxweight = tapply(PlantGrowth$weight,PlantGrowth$group,max)
class(maxweight)
names(maxweight)
class(as.table(maxweight))
as.data.frame(as.table(maxweight))
as.data.frame.table(as.table(maxweight),
                    responseName='MaxWeight')

#8.5 Mapping a Function Based on Groups 115

#Unlike aggregate, tapply is not limited to returning scalars. For example,
#if we wanted the range of weights for each group in the PlantGrowth dataset,
#we could use
ranges = tapply(PlantGrowth$weight,PlantGrowth$group,range)
class(ranges)

#116 8 Data Aggregation
dimnames(ranges)
dimnames(ranges)[[1]]
data.frame(group=dimnames(ranges)[[1]],
           matrix(unlist(ranges),ncol=2,byrow=TRUE))

CO2
head(CO2)
class(CO2)
summary(CO2)
ranges1 = tapply(CO2$uptake,CO2[c('Type','Treatment')],range)
#The returned value is a matrix of lists
ranges1





















#date



mydate = as.POSIXlt('2005-4-19 7:01:00')
mydate
names(mydate)

ISOdate
b1 = ISOdate(1977,7,13)
b2 = ISOdate(2003,8,14)
b2 - b1
difftime(b2,b1,units='weeks')
as.difftime(c(0,30,60), units = "mins")