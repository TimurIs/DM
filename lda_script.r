#Script to compute TF-IDF of the given corpus

if(!require("LaplacesDemon"))
{
	install.packages("LaplacesDemon", repos='http://cran.us.r-project.org')
	library("LaplacesDemon")
}

if(!require(tm))
{
	install.packages(tm, repos='http://cran.us.r-project.org')
	library(tm)
}

if(!require(topicmodels))
{
	install.packages(topicmodels, repos='http://cran.us.r-project.org')
	library(topicmodels)
}

#SETWorkingDirectory
setwd("/home/timur/Desktop/R_dir")

#Need only .txt files
filenames <- list.files(getwd(), pattern="*.txt")

#remove strange symbols (nul end?)
files <- lapply(filenames, function(x) {tt <- tempfile(); system(paste0("tr < ", x, " -d '\\000' >", tt)); readLines(tt)})

docs <- Corpus(VectorSource(files))

#to save memory, if required
remove(files)

#preprocess the corpus

#this is the same next 5 lines of code in 1 line
#docs <- tm_map(tm_map(tm_map(tm_map(tm_map(docs, content_transformer(tolower)), removeNumbers), removePunctuation), removeWords, stopwords("english")), stripWhitespace)

docs <- tm_map(docs, content_transformer(tolower))		#to lower case
docs <- tm_map(docs, removeNumbers)				#remove all numbers
docs <- tm_map(docs, removePunctuation)				#remove punctuation
docs <- tm_map(docs, removeWords, stopwords("english"))		#stop words remove
docs <- tm_map(docs, stripWhitespace)				#remove extra whitespaces

#Stem document
docs <- tm_map(docs,stemDocument)

dtm <- DocumentTermMatrix(docs)
test_dtm = dtm[nrow(dtm)-5:nrow(dtm),]
train_dtm = dtm[1:nrow(dtm)-6,]

#to save memory, if required
remove(docs)

#Set parameters for Gibbs sampling //Taken from web example for now

#Don't really understand at this point what this parameters help to achive.
burnin <- 4000
iter <- 2000				#Number of iterations for LDA
thin <- 500		
seed <-list(2003,5,63,1001,765)		#Random start points (doc number 2003, 5, 63 etc)
nstart <- 5				#Number of repeats (?)
best <- TRUE				#choose best result

#Number of topics
k <- 50 #Random at this point

#Run LDA using Gibbs sampling
#ldaOut <-LDA(dtm,k, method=”Gibbs”, control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin)) #Never ended at this point

lda <- LDA(train_dtm, k, method = "Gibbs")
test.topics <- posterior(lda,test_dtm)

print(test.topics$topics)
print(posterior(ldaOut)$topics)

###############################
#TO DO: Should be loop over all test (unseen) documents loop over all seen (posterior(ldaOut)$topics) docements. Pick the lowest KL-D. Or even sort from min to max.
###############################
px <- test.topics$topics[1,]
py <- posterior(ldaOut)$topics[1,]

kl.d <- KLD(px,py) #KL-Divergance 
print(kl.d)

lda.topics <- as.matrix(topics(lda))
print(lda.topics)
