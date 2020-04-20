### Loading in libraries
# remember, if you don't have these, you can install libraries with `install.packages("tidyverse")` for instance.
library(tidyverse)

### Importing data

## Normal way
gene_data <- read.delim("test-data-skoog.txt")
# ?read.delim()

# Data are representative of taxa as rows and columns showing genes (values equal copies of those genes for each taxa). These 4 genes are required for the full pathway. We will show some examples of how to subset, filter, and perform basic calculations.


# Data frame versus matrix in R
## Data frames can include different types of data
class(gene_data)
head(gene_data)
str(gene_data) # Factors and integers included in this data

## Tidyverse way
# Tidyverse are a series of related packages with related syntax. This includes functions for reading data.
# this funciton requires you to tell R what your "delimiter" is. Thats the charact
gene_data_tidy <- read_delim("test-data-skoog.txt", delim = "\t")
# Lets see the differences between this and the other fomat

class(gene_data_tidy)
head(gene_data_tidy)
str(gene_data_tidy)

## Some key differences. 
# The object is a "tibble" in addition to being a data frame.
# Text columns are character vectors, instead of factors (easier to deal with)

### So matrices...
# When do you use one over the other? It depends on what kind of data you're working with. If you're working with different types of information in the same table, you likely need a data frame. But if you're working with a single data type, a matrix may be better for you. Additionally, matrices are more efficient with respect to memory. Therefore, a lot of statistical tools/methods require a matrix as input. We will review this. #Compare str() results
gene_mat <- as.matrix(gene_data)
str(gene_mat)
# str(gene_data)
View(gene_mat)

### Let's work with the data frame version of our test data

# Colnames and rownames, "index" what appears in the columns and rows. It is like the bar A-Z at the top and the numbers on the left side bar of an Excel table.

colnames(gene_data) # reports all of my column names! 

# Let's change some of these because there is a typo
colnames(gene_data)[6] <- "GENE_D" #Changes the 6th column name to "GENE_D"
# Change columns headers for columns 4-6
colnames(gene_data)[4:6] <- c("GENE_C", "GENE_B", "GENE_D")

colnames(gene_data) # Check output

# Example of how to change the order (2 ways) - Which way would be more reproducible?
colnames(gene_data)
# Option 1
gene_data_reorder <- gene_data[, c("Taxon", "MAG","GENE_A", "GENE_B", "GENE_C", "GENE_D")]
head(gene_data_reorder)
# Option 2
tmp <- gene_data[c(1:3,5,4,6)] #Combine specific columns "c()"
head(tmp)
## Tidyverse version of renaming and reordering columns.
# `%>%` is called a "pipe"
# Let's restart by importing again.
gene_data <- read.delim("test-data-skoog.txt")
head(gene_data)
# Fix column name
# colnames(gene_data)[6] <- "Gene_d"
gene_data_fix <- gene_data %>% rename(GENE_D = Gene_d)
?rename()
# Fix order
gene_data_reorder <- gene_data_fix %>% select(Taxon, MAG, GENE_A, GENE_B, GENE_C, GENE_D)
head(gene_data_reorder)
# another way of re ordering, does same as above
# Everything says use everything that is left. Often nice when you are just trying to bring one variable to the left of a data.frame or tibble
gene_data_reorder <- gene_data_fix %>% select(Taxon, MAG, GENE_A, GENE_B, everything())
# ?everything()
gene_data_fixedup <- gene_data %>%
  rename(GENE_D = Gene_d) %>%
  select(Taxon, MAG, GENE_A, GENE_B, everything())
head(gene_data_fixedup)

# Let's subset our data with subset() in base R
# I only want MAGs (rows or entries) where Gene A is greater than zero
head(gene_data_fixedup[1:3,])
tmp1 <- subset(gene_data_fixedup, !(GENE_A == 0 ))
tmp1 <- subset(gene_data_fixedup, GENE_A > 0)

## Other option if I wanted to select rows where both GENE C and D were greater than zero.
# tmp1 <- subset(gene_data_fixedup, (GENE_C > 0 & GENE_D > 0))

# Let's repeat this with tidyverse instead.
# ?filter()
tmp2 <- filter(gene_data_fixedup, GENE_A > 0)

## Tidyverse subsetting
tmp_tidy <- gene_data_fixedup %>% filter(GENE_C > 0 & GENE_D > 0)
# another way of doing the above
tmp_tidy <- gene_data_fixedup %>% filter(GENE_C > 0, GENE_D > 0)
# a third way of doing the above
tmp_tidy <- gene_data_fixedup %>% filter(GENE_C > 0) %>% filter(GENE_D > 0)
## as in tmp2 but tidy
tmp2_tidy <- gene_data_fixedup %>% filter(GENE_A != 0)
# more like other way, does same thing
tmp2_tidy <- gene_data_fixedup %>% filter(!(GENE_A == 0))


# What if I want to filter a set of MAGs of interest?
mags_i_want <- c("MAG_4", "MAG_12", "MAG_24", "MAG_18")

tmp3 <- filter(gene_data_fixedup, MAG %in% mags_i_want)

# How would we combine all of the statements above?
## Filter by GENE A presence and the MAGs I want?
gene_data_filtered <- gene_data_fixedup %>%
  filter(GENE_A > 0 & MAG %in% mags_i_want)


# Let's string everything together again.

gene_data_ <- gene_data %>% 
  rename(GENE_D = Gene_d) %>%
  select(Taxon, MAG, GENE_A, GENE_B, everything()) %>%
  filter(GENE_A > 0 & MAG %in% mags_i_want)



# This data is in wide format. Convert to long format - this is more versatile in R.
## Compare long vs. wide format
# ?pivot_longer()
# ?pivot_wider()
colnames(gene_data_fixedup)
gene_data_long <- gene_data_fixedup %>%
  pivot_longer(GENE_A:GENE_D, names_to = "GENE", values_to = "COUNT")


# View(gene_data_fixedup)
# View(gene_data_long)

# Split Taxon column
gene_data_long_cols <- gene_data_long %>%
  separate(Taxon, c("phylum", "class", "order", "family", "genus", "species"), sep = ";", remove = FALSE)
head(gene_data_long_cols)


#Lets combine the two operations from above.
gene_data_long <- gene_data_fixedup %>%
  pivot_longer(GENE_A:GENE_D, names_to = "GENE", values_to = "COUNT") %>%
  separate(Taxon, c("phylum", "class", "order", "family", "genus", "species"), sep = ";", remove = FALSE) %>%
  data.frame
# head(gene_data_long)

# Mean at Class level - across whole dataset (add Min and Max value to demonstrate syntax)
# ?summarise()
mean_class <- gene_data_long %>%
  group_by(class, GENE) %>%
  summarise(MEAN = mean(COUNT)) %>%
  data.frame
# head(mean_class)


# Relative abundance of genes by Taxon
# ?mutate()
relabun_all <- gene_data_long %>%
  group_by(class, GENE) %>%
  mutate(RELABUN = (COUNT/sum(COUNT))) %>%
  data.frame
head(relabun_all)

## Check relative abundance calculation
# alpha_test <- filter(relabun_all, class %in% "c__Alphaproteobacteria")
# View(alpha_test)
# sum(alpha_test$RELABUN)


# Add additional calculations to the above summarise and mutate functions.
# ?n()
# ?n_distinct()
# ?median()
# ?max()
# ?min()
# ?var()
# ?sd()
