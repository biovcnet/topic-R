# We will work with the iris database, which comes with R. This is how you load it:
data("iris")

# Get a general idea of the iris table
str(iris)
head(iris)
nrow(iris)
ncol(iris)
colnames(iris)
rownames(iris)
# You can change a columns name like this
colnames(iris)[2] <- "Sep.Wid"
colnames(iris)[2] <- "Sepal.Width"

# Transposing a table

# Sorting the table
iris[order(iris$Petal.Length, decreasing=TRUE),]
# Sorting by multiple columns
iris[order(iris$Species, iris$Petal.Length),]
# Sorting by multiple columns - species and decreasing petal length
iris[order(iris$Species, -iris$Petal.Length),]
#
# Filtering by column value: I have to exclude the last column from the analysis 
# because it's not numeric. See what happens when you don't exclude it!
iris[iris$Sepal.Length>7,]
iris[iris$Species=="setosa",]

# Summing by row/column
colSums(iris[,-ncol(iris)])
rowSums(iris[,-ncol(iris)])

# Get the mean value per column
colMeans(iris[,-ncol(iris)])

# Converting to relative abundance
# This isn't meaningful when using the iris database, so let's use an OTU counts table
# There are two ways to do this. One involves looping through all the rows, 
# and the other uses a very important function in R called "apply".

# First let's read an OTU table into a variable
OTUs <- read.csv("OTUtable.csv")
str(OTUs)

# Let's start with a loop
# First let's save the column sums into a vector named vec
# We want to exclude the OTU number and the taxonomy
vec <- colSums(OTUs[,-c(1, ncol(OTUs))])
# We'll manipulate a new table named iris2 (you could also manipulate your original table)
# Here we are going row by row and dividing the cells in that row by the vector of column sums
# R will divide the first cell in the row by the first cell in the vector, 
# the second by the second etc.
relabun <- OTUs
for (r in 1:nrow(relabun)) {
  relabun[r,-c(1, ncol(relabun))] <- relabun[r,-c(1, ncol(relabun))]/vec
}
head(relabun)
# If we want the numbers to look like percentages rather than fraction we can multiply them all by 100
relabun[,-c(1, ncol(relabun))] <- relabun[,-c(1, ncol(relabun))]*100
head(relabun)

# Now let's do the same with apply
# Define a function that divides a row by the vector of column sums (vec)
relabun <- OTUs
divByColsum <- function(x) {x/vec}
relabun <- apply(OTUs[,-c(1, ncol(OTUs))], 1, divByColsum)
head(relabun)
# Notice that apply transposes the table, so let's run it again and also transpose the output
relabun <- t(apply(OTUs[,-c(1, ncol(OTUs))], 1, divByColsum))
str(relabun)
# Iris2 is now a list, which is a different data type in R. We want a data frame:
relabun <- as.data.frame(t(apply(OTUs[,-c(1, ncol(OTUs))], 1, divByColsum)))
str(relabun)

# Sadly now we don't have the OTU_ID and taxonomy columns
# We can use the function merge to merge two table by a column that exists in both of them that has unique IDs
# We don't have a variable like this here, but we haven't changed the order of rows, 
# so we can use row names as an ID variable
relabun2 <- merge(relabun2, OTUs, by="row.names")
head(relabun2)
# Oops, now we have both counts and relative abundance in the same table as well as an additional
# variable names Row.names.
# Let's try again:
relabun2 <- merge(relabun, OTUs[,c(1, ncol(OTUs))], by="row.names")
head(relabun2)
# Throwing out the Row.names column
relabun2 <- relabun2[,-1]
head(relabun2)
# Sadly row names is not a numeric variable, but a string. That's why relabun2 isn't sorted like OTUs
# What if we actually had a common column like OTU_ID between the tables we're merging?
relabun3 <- relabun2[,-ncol(relabun2)] # OTU_ID and samples
relabun4 <- relabun2[,c(ncol(relabun2)-1, ncol(relabun2))] # OTU_ID and taxonomy
# Now we have 2 tables where column 1 is common between them
relabun5 <- merge(relabun3, relabun4, by="OTU_ID")

# What if we the column we're using to merge has a different name in each table?
colnames(relabun4)[1] <- "George"
relabun5 <- merge(relabun3, relabun4, by.x="OTU_ID", by.y="George")

