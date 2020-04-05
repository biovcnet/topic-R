# Basic operators and intro to some syntax
# Sept. 5th 2018 MI591
# E. Suter

# Basic operators
5+5
5-5
3*5
15/2
2^2
45/6
45%%6

#Assigning Variables & directionality
x <- 42
x

# Lists and calling
x <- c(1,7,9)
x[2]

apples <- 5
oranges <- 6
apples + oranges
fruit <- apples+oranges

# data types
oranges <- "grapefruit"
class(oranges)

oranges <- 6
class(oranges)

oranges <- "6"
class(oranges)

mylogical <- FALSE
class(mylogical)

# see further: https://www.tutorialspoint.com/r/r_data_types.htm

# Create vector
numeric_vector <- c(1, 10, 49)
character_vector <- c("a", "b", "c")

names(numeric_vector) <- character_vector
numeric_vector
x+numeric_vector

ans <- x>numeric_vector
ans


# Matrices
matrix(1:9, byrow = FALSE, nrow = 3)


q <- c(460, 314)
r <- c(290, 247)
w <- c(309, 165)

c(q, r, w)
mydataset <- matrix(c(q, r, w), byrow = TRUE, nrow = 3)
mydataset

region <- c("one", "two")
category <- c("A","B","C")

rownames(mydataset) <- category
colnames(mydataset) <- region

mydataset

rowSums(mydataset)

totals <- rowSums(mydataset)

cbind(mydataset,totals)



