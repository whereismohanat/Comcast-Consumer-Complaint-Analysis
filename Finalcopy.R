#Injesting the dataset into the R environment
setwd("/cloud/project")
getwd()
cust_com = read.csv("Comcast Telecom Complaints data.csv",stringsAsFactors = T)

#Verifying for any discrepancies in the ingested data.
##View(cust_com)
str(cust_com)
#Data Cleaning
#Convert Dates into R Date Type
#install.packages("lubridate")
library(lubridate) 
mdy = mdy(cust_com$Date)
dmy = dmy(cust_com$Date)
mdy[is.na(mdy)] <- dmy[is.na(mdy)]
cust_com$Date = mdy
rm(dmy,mdy)

#Verifying for change in Date Datatype
str(cust_com$Date)

#Daily and Monthly Chart
#install.packages("dplyr")
library(dplyr)
library(ggplot2)
library(scales)


#Daily Trend Chart
a=data.frame(cust_com$Date)
colnames(a)=c("Dates")
m=a %>% group_by(Dates) %>% summarise(frequency = n())

str(m)
ggplot(m, aes(Dates, frequency)) + geom_line()+
  scale_x_date(date_labels = "%d/%m/%y",date_breaks = "1 day")+
  theme(axis.text.x = element_text(angle = 60, hjust = 1))


#Monthly Trend with dame data
#install.packages("tidyverse")
library(tidyverse)
b=data.frame(a)
#View(b)
colnames(b)=c("Months")
b=month(b$Months)
str(b)
b=as.data.frame(b)
d <- transform(b,MonthAbb = month.abb[b])
d=d$MonthAbb
#View(d)
d=as.data.frame(d)
d=d %>% group_by(d) %>% summarise(frequency = n())
str(b)
barplot(d$frequency,names.arg = d$d)
ggplot(d, aes(x=d,y=frequency)) + geom_bar()

#Now we convert the Data Frame c$Status into a categorical Variable
cust_com$Status=as.character(cust_com$Status)
str(cust_com$Status)

cust_com$Status[cust_com$Status %in% c("Open","Pending")] <- "Open"
cust_com$Status[cust_com$Status %in% c("Closed","Solved")] <- "Closed"
cust_com$Status=as.factor(cust_com$Status)
levels(cust_com$Status)

#Frequency of Complaint Types
#install.packages("tm")
#install.packages("wordcloud")
library(tm)
library(wordcloud)
##View(cust_com)

complaint_list = data.frame(cust_com$Customer.Complaint)
colnames(complaint_list)=c("Complaint")
##View(complaint_list)
corpus= Corpus(VectorSource(complaint_list$Complaint))

corpus [[2]][1]
#Text Cleaning

#Converting all text into lower case

corpus <- tm_map(corpus,content_transformer(tolower))
corpus [[2]][1] #Everything turned to lower case
#Remove Numbers
corpus<- tm_map(corpus,removeNumbers)

corpus[[4]][1] # There was a number before line execution

#Removing common stop words
corpus = tm_map(corpus,removeWords,stopwords(kind="en"))

corpus[[4]][1] # Words like 'a' 'the' of got removed

#Remove Punctuation
corpus = tm_map(corpus,removePunctuation)

#Removing white spaces
corpus = tm_map(corpus,stripWhitespace)
corpus[[4]][1]

#Remove additional words

corpus= tm_map(corpus,removeWords,c("get","took","can","can","comcast"))

#Create Term Document Matrix (TDM)

tdm = TermDocumentMatrix(corpus)
m=as.matrix(tdm)
v=sort(rowSums(m),decreasing = T)
#List with Frequency of Compliant Types
d=data.frame(word=names(v),freq=v)

#View(d)
set.seed(2)
wordcloud(d$word,d$freq,random.order=F,min.freq = 1,rot.per =0,scale = c(4,.5),max.words = 100,colors = brewer.pal(8,"Dark2"))
title(main = "Complaint Types - Word Cloud",font.main=1,cex.main=1.5)

#State wise status of complaints in stacked bar chart

#Making a Frequency Data Frame by State

c=data.frame(cust_com$State,cust_com$Status)
str(c)
summary(c)
c
c_tac=table(c)
c_tac
##View(c_tac)
c_pok=data.frame(c_tac)
c_pok
colnames(c_pok)=c("States","Status","Frequency")
#View(c_pok)
str(c_pok)
#States with Maximum Complaints
#install.packages("viridis")
#install.packages("hrbrthemes")
library(ggplot2)
library(viridis)
library(hrbrthemes)
ggplot(c_pok,aes(fill=Status,x=Frequency,y=States),)+
  geom_bar(position="stack", stat="identity") +
  scale_fill_viridis(discrete = T) +
  ggtitle("Complaint Status by State") +
  theme_ipsum() +
  xlab("Count")

#States with Maximum Complaints

max_comp <- data.frame(cust_com$State)
View(max_comp)
max_comp=max_comp %>% group_by(cust_com.State) %>% summarise(frequency = n())
colnames(max_comp)=c("States","Freq")
max_comp=max_comp[order(max_comp$Freq,decreasing = T),]
head(max_comp)


#States with highest percentage of Unresolved Complaints
sum(unresol_comp$Frequency)
unresol_comp=data.frame(c_pok[44:86,])
rownames(unresol_comp)=c_pok$States[44:86]
colnames(unresol_comp)=c("State","Status","Freq")
#View(unresol_comp)
unresol_comp$Per= (unresol_comp$Freq/sum(unresol_comp$Freq))*100

unresol_comp=unresol_comp[order(unresol_comp$Per,decreasing = T),]
View(unresol_comp)
unresol_comp$Per =format(unresol_comp$Per,digits=2)
head(unresol_comp)

#the percentage of complaints resolved till date,
#which were received through the Internet and customer care calls.

com_res_td = data.frame(cust_com$Received.Via)
colnames(com_res_td)= c("Received Via")
com_res_td=com_res_td %>% group_by(`Received Via`) %>% summarise(frequency = n())
com_res_td

com_res_td$Percentage =  percent(com_res_td$frequency/2224)
com_res_td



