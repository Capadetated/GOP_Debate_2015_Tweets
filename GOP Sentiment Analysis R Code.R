# This program contains all the R code used for analysis on the 2015 GOP Debate Tweets Sentiment Analysis 
# Data 650
# Theodore Fitch
# Last updated 16JUL24

# Load required libraries
library(plyr)
library(ggplot2)
library(dplyr)
library(arules)
library(arulesViz)
library(tm)
library(wordcloud)
library(SnowballC)
library(cluster)
library(igraph)
library(syuzhet)
library(topicmodels)

# Read the data from object storage
SENTIMENT <- read.csv("~/project-objectstorage/First_GOP_Debate.csv", stringsAsFactors=FALSE)

# Check the row counts
nrow(SENTIMENT)

# Number of tweets per sentiment
table(SENTIMENT$SENTIMENT)

# Number of tweets per candidate
table(SENTIMENT$CANDIDATE)

# Number of tweets per sentiment by candidate
table(SENTIMENT$CANDIDATE, SENTIMENT$SENTIMENT)

# Number of tweets by candidate per subject matter
table(SENTIMENT$SUBJECT_MATTER, SENTIMENT$CANDIDATE)

# Pie charts
# Reset the margin
par(mar=c(1,1,1,1))
# Use default colors
pie(table(SENTIMENT$CANDIDATE))
# Change colors
pie(table(SENTIMENT$CANDIDATE), col=c("blue", "yellow", "green", "purple", "pink", "orange"))

# List the most common subjects
reasonCounts <- na.omit(plyr::count(SENTIMENT$SUBJECT_MATTER))
reasonCounts <- reasonCounts[order(reasonCounts$freq, decreasing=TRUE), ]
reasonCounts

# Subjects frequency plot
wf <- data.frame(reasonCounts)
p <- ggplot(wf, aes(wf$x, wf$freq))
p <- p + geom_bar(stat="identity")
p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))
p

# Number of retweets per subject matter
ddply(SENTIMENT, ~ SUBJECT_MATTER, summarize, numRetweets = sum(RETWEET_COUNT, na.rm = TRUE))

# Posts that have more than 4000 retweets
as.character(subset(SENTIMENT, RETWEET_COUNT > 4000)$TEXT)

# Parse the date-time with the correct format
SENTIMENT$TWEET_CREATED <- as.POSIXct(SENTIMENT$TWEET_CREATED, format = "%m/%d/%Y %H:%M", tz = "UTC")

# Ensure date-time conversion was successful
head(SENTIMENT$TWEET_CREATED, 10)

# Number of posts per day
posts <- as.Date(SENTIMENT$TWEET_CREATED)
table(posts)
# Day with the maximum number of posts
table(posts)[which.max(table(posts))]

# Number of posts per day by sentiment plot
drs <- SENTIMENT[, c('TWEET_CREATED', 'SENTIMENT')]
drs$TWEET_CREATED <- as.Date(drs$TWEET_CREATED)
# Calculate and plot number of tweets per day by sentiment
ByDateBySent <- drs %>% group_by(SENTIMENT, TWEET_CREATED) %>% dplyr::summarise(count = n())
ByDateBySentPlot <- ggplot() + geom_line(data=ByDateBySent, aes(x=TWEET_CREATED, y=count, group=SENTIMENT, color=SENTIMENT)) 
ByDateBySentPlot

# Apriori rules method
dfa <- SENTIMENT[, c('CANDIDATE', 'SENTIMENT', 'SUBJECT_MATTER', 'RETWEET_COUNT', 'USER_TIMEZONE')]
dfa$CANDIDATE <- as.factor(dfa$CANDIDATE)
dfa$SENTIMENT <- as.factor(dfa$SENTIMENT)
dfa$SUBJECT_MATTER <- as.factor(dfa$SUBJECT_MATTER)
dfa$USER_TIMEZONE <- as.factor(dfa$USER_TIMEZONE)
dfa$RETWEET_COUNT <- cut(dfa$RETWEET_COUNT, breaks=c(0, 1, 2, Inf), right=F, labels=c("0", "1",  "2+"))

rules <- apriori(dfa, parameter = list(supp = 0.001, conf = 0.8))

# Check the number of rules generated
num_rules <- length(rules)
print(paste("Number of rules generated:", num_rules))

# Inspect the available rules
if(num_rules > 0) {
  arules::inspect(rules[1:min(15, num_rules)])
} else {
  print("No rules generated.")
}

# Plot the rules, adjusting the max parameter to handle the number of rules
plot(rules, method="graph", control=list(max=33), alpha=1, cex=0.9)


# Load the required libraries
library("tm")
library("wordcloud")
library("SnowballC")

# Use the subsequent code for troubleshooting (5 sections)
# Check the structure of the SENTIMENT dataframe
str(SENTIMENT)

# Ensure the SENTIMENT column contains the expected values
unique(SENTIMENT$SENTIMENT)

# Verify the existence of the TEXT column
if ("TEXT" %in% colnames(SENTIMENT)) {
  # Filter positive sentiment tweets
  positive <- SENTIMENT[SENTIMENT$SENTIMENT == 'Positive', 'TEXT']
  
  # Check if positive contains any data
  if (length(positive) > 0) {
    # Create a corpus
    docs <- Corpus(VectorSource(positive))
  } else {
    stop("No positive sentiment tweets found.")
  }
} else {
  stop("The column 'TEXT' does not exist in the SENTIMENT dataframe.")
}

print(head(SENTIMENT$SENTIMENT, 20))

# Verify the existence of the TEXT column
if (!"TEXT" %in% colnames(SENTIMENT)) {
  stop("The column 'TEXT' does not exist in the SENTIMENT dataframe.")
}

# Filter positive sentiment tweets
positive <- SENTIMENT[tolower(SENTIMENT$SENTIMENT) == 'positive', 'TEXT']

# Check if positive contains any data
if (length(positive) == 0) {
  stop("No positive sentiment tweets found.")
}

# Create a corpus
docs <- Corpus(VectorSource(positive))

# Inspect the first few documents to ensure the corpus was created correctly
inspect(docs[[1]])
inspect(docs[[2]])
inspect(docs[[min(10, length(docs))]])

# Strip the white space
docs <- tm_map(docs, stripWhitespace)

# Remove the URLs
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
docs <- tm_map(docs, content_transformer(removeURL))

# Remove non-ASCII characters
removeInvalid <- function(x) gsub("[^\x01-\x7F]", "", x)
docs <- tm_map(docs, content_transformer(removeInvalid))

# Remove punctuation
docs <- tm_map(docs, removePunctuation)

# Remove the numbers
docs <- tm_map(docs, removeNumbers)

# Convert to lowercase
docs <- tm_map(docs, content_transformer(tolower))

# Replace specific characters with space
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "@")   # Remove @
docs <- tm_map(docs, toSpace, "/")   # Remove /
docs <- tm_map(docs, toSpace, "\\|") # Remove |

# Remove stop words
docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, removeWords, stopwords("SMART"))

# Apply stemming
docs <- tm_map(docs, stemDocument)

# Remove the white space introduced during the pre-processing
docs <- tm_map(docs, stripWhitespace)

# Create Document-Term Matrix
dtm <- DocumentTermMatrix(docs)

# Convert dtm to a matrix and inspect dimensions
m <- as.matrix(dtm)
dim(m)                # Display number of terms and number of documents
View(m[1:10, 1:10])   # Preview the first 10 rows and the first 10 columns in m

# Find the terms that appear at least 50 times
findFreqTerms(dtm, lowfreq=50)

# Find the terms associated with "good" and "great" with correlation at least 0.15
findAssocs(dtm, c("great", "good"), corlimit=0.15)

# Prepare the data (max 60% empty space)
dtms <- removeSparseTerms(dtm, 0.6)

# Find word frequencies
freq <- colSums(as.matrix(dtm))

# Generate word cloud
dark2 <- brewer.pal(6, "Dark2")
wordcloud(names(freq), freq, min.freq=35, max.words=100, rot.per=0.2, scale=c(0.9, 0.9), colors=dark2)

# Remove sparse terms
dtms <- removeSparseTerms(dtm, 0.98)

# Build the dissimilarity matrix
d <- dist(t(dtms), method="euclidean")

# Perform hierarchical clustering and plot dendrogram
fit <- hclust(d, method="ward.D2")
plot(fit, hang=-1)

library("igraph")

# Create Term Document Matrix and remove sparse terms
tdm <- TermDocumentMatrix(docs)
tdm <- removeSparseTerms(tdm, 0.96)

# Convert tdm to matrix and set non-zero entries to 1
termDocMatrix <- as.matrix(tdm)
termDocMatrix[termDocMatrix >= 1] <- 1

# Create term-term adjacency matrix
termMatrix <- termDocMatrix %*% t(termDocMatrix)
View(termMatrix)

# Create graph from adjacency matrix
g <- graph.adjacency(termMatrix, weighted=T, mode="undirected")
g <- simplify(g)  # Remove self-loops

# Set vertex attributes and plot graph with various layouts
V(g)$label <- V(g)$name
V(g)$degree <- degree(g)
set.seed(3952)

plot(g, layout=layout.fruchterman.reingold(g), vertex.color="cyan")
plot(g, layout=layout_with_gem(g), vertex.color="pink")
plot(g, layout=layout_as_star(g), vertex.color="yellow", vertex.shape="square")
plot(g, layout=layout_on_sphere(g), vertex.color="magenta")
plot(g, layout=layout_randomly(g), vertex.size=10)
plot(g, layout=layout_in_circle(g), vertex.color="pink", vertex.size=15)
plot(g, layout=layout_nicely(g), vertex.color="plum", vertex.size=25)
plot(g, layout=layout_on_grid(g), vertex.color="green", vertex.size=10)
plot(g, layout=layout_as_tree(g), vertex.color="brown", vertex.size=10)

# Find maximal cliques in the graph
cl <- maximal.cliques(g)

# Assign colors to cliques and plot
colbar <- rainbow(length(cl) + 1)
for (i in 1:length(cl)) { V(g)[cl[[i]]]$color <- colbar[i + 1] }
plot(g, mark.groups=cl, vertex.size=.3, vertex.label.cex=1.2, edge.color=rgb(.4,.4,0,.3))

# Remove sparse terms and calculate distance matrix
dtms <- removeSparseTerms(dtm, 0.99)
d <- dist(t(dtms), method="euclidean")

# Perform k-means clustering
kfit <- kmeans(d, 5)
clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, labels=2, lines=0)
print(kfit)

# Plot between-cluster sum of squares
bss <- integer(length(2:15))
for (i in 2:15) bss[i] <- kmeans(d, centers=i)$betweenss
plot(1:15, bss, type="b", xlab="Number of Clusters", ylab="Sum of squares", col="blue")

# Plot within-cluster sum of squares
wss <- integer(length(2:15))
for (i in 2:15) wss[i] <- kmeans(d, centers=i)$tot.withinss
lines(1:15, wss, type="b")
