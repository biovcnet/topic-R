## README for BVCN Lesson 3 - R

### Import test data
```
gene_data <- read.delim("test-data-skoog.txt")
```

#### Review data frames versus matrices
Data frames can include different types of data
```
class(gene_data)
head(gene_data)
str(gene_data) # Factors and integers included in this data
```

When do you use one over the other? It depends on what kind of data you're working with. If you're working with different types of information in the same table, you likely need a data frame. But if you're working with a single data type, a matrix may be better for you. Additionally, matrices are more efficient with respect to memory. Therefore, a lot of statistical tools/methods require a matrix as input. We will review this. #Compare str() results
```
gene_mat <- as.matrix(gene_data)
str(gene_mat)
str(gene_data)
View(gene_mat)
```

### Introduction to tidyverse

Discussion of base R commands that are common.
* Compare subset() and filter(). Review condtional statements for subset() and filter().
* Pipe operator
* Cheat sheet (https://github.com/rstudio/cheatsheets/raw/master/data-transformation.pdf)
* Convert to long format
* Calculate relative abundance and more! summarise() and mutate()
