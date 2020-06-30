#
# Ordinations Part II.
# R lesson 8b | Amplicon lesson 5b
# BVCN - R topic

# Written by Daniel Muratore & Sarah Hu
## Please cite/read - Coenen AR, Hu SK, Luo E, Muratore D, Weitz JS. A Primer for Microbiome Time-Series Analysis. Front Genet. 2020 Apr 21;11:310.
# Original (and more):
# https://github.com/WeitzGroup/analyzing_microbiome_timeseries

# Load libraries
# install.packages(c("ape", "compositions", "plotly", "RColorBrewer", "tidyverse", "vegan", "cowplot"))
library(compositions); library(tidyverse); library(vegan); library(ape)
library(cowplot);library(plotly);library(RColorBrewer)

load("diel-test-data.RData", verbose = TRUE)

# What is this data type? 
head(diel)
colnames(diel)
unique(diel$Level2)

# QC and filtering
diel_qced <- diel %>% 
  # Remove OTUs without assignments
  filter(!(Level1 == "None" | Level2 == "X" | Level2 == "Eukaryota_X")) %>%
  # Remove singletons
  mutate(otu_sum = rowSums(select_if(., is.numeric))) %>% 
  filter(otu_sum > 1) %>% 
  # Select OTU count data only, set row names
  select(OTU.ID, ends_with(c("PM", "AM"))) %>% 
  column_to_rownames(var = "OTU.ID") %>% 
  data.frame
head(diel_qced)

# Select taxonomy information, make a key
tax_key <- diel %>% 
  select(OTU.ID, starts_with("Level")) %>% 
  data.frame
head(tax_key)

#
# OTU and ASV data are compositional
#
## Composition data does not represent true absolute abundances. The total number of sequences in your data is arbitrary. Meaning, with an increase in the relative abundance of an OTU/ASV (or taxa) this necessarily decrease the relative abundance of all other members. Because these data are compositional, they are on a simplex. The data being on a simplex means, if we know the abundances of all of the OTUs except for one, we still have the same amount of information as if we knew all of the OTUs. This is important to acknowledge when you approach amplicon data analysis and interpretation.

## References / recommended reading:
# (1) THIS TUTORIAL: Coenen AR, Hu SK, Luo E, Muratore D, Weitz JS. A Primer for Microbiome Time-Series Analysis. Front Genet. 2020 Apr 21;11:310.
# (2) Gloor, G. B., Macklaim, J. M., Pawlowsky-Glahn, V. & Egozcue, J. J. Microbiome Datasets Are Compositional: And This Is Not Optional. Front. Microbiol. 8, 57–6 (2017).
# (3) Weiss, S. et al. Normalization and microbial differential abundance strategies depend upon data characteristics. Microbiome 5, 1–18 (2017).
# (4) McMurdie, P. J. & Holmes, S. Waste Not, Want Not: Why Rarefying Microbiome Data Is Inadmissible. PLoS Comput Biol 10, e1003531 (2014).
# (5) Silverman JD, Washburne AD, Mukherjee S, David LA. A phylogenetic transform enhances analysis of compositional microbiota data. eLife. 2017 Feb 15;6:e21887. 


## Evidence of compositionality (diagnostic):
# Do I need to transform my data?

# Estimate covariance matrix for OTUs
covariance_matrix <- as.matrix(diel_qced) %*% t(diel_qced)
# %*% = matrix multiplication sign in R; used here to multiply OTU/ASV data matrix to itself to estimate covariance.

# Evaluate determinant of covariance matrix
cov_determinant <- det(covariance_matrix)
cov_determinant # The determinant of the covariance matrix (what we just calculated) is equivalent to the product of the proportion of variance explained by every PCA axis. If the determinant is 0, that means there is an axis which explains 0 variance that we can't separate from the other axes. The data need to be transformed to be suitable for PCA. 

#
# Data transformations
#

## Another approach to PCA ordination w/Compositional Data: Log-Ratio Transformations
# Log-ratio - combat issues with variance and distribution, all variables will be transformed to be relative to the abundance of an arbitrary focal taxon. Divide all the count data by the abundance of a focal taxa and take the natural log.  So why do this? This is one way we can transform our amplicon data to be more appropriate/more suitable for many statistical approaches. 
## ilr - isometric log ratio
## clr - centered log ratio, values will be centered around the geometric average

diel_log_rats <- data.frame(compositions::ilr(t(diel_qced)))
# diel_log_rats <- data.frame(ilr(t(diel_qced)))
# These are complicated to interpret however because you move from D simplex to D-1 euclidean. But using these we can see we are now in invertible covariance regime.

## Checking the difference the log-ratio made on the data characteristics
new_covdet <- det(as.matrix(diel_log_rats) %*% t(diel_log_rats))
cov_determinant #Original Count Data
new_covdet # After doing a log ratio, you see that none of the axes are equal to 0. Therefore the axes for PCoA explain variance.

## Visualize these axes - recall what the goal of an ordination is for this type of data
# Ordinations - taking complex data and working to present it in 2-3 dimensions, we are placing a new coordinate system (fitting) in place. Principle Component Analysis (PCA) works to generate this coordinate system that is most appropriate for your data. Evaluated based on the eigen decomposition from sample covariance matrix. (Eigenvectors = principle axes)
# ?prcomp()
lograt_pca <- prcomp(diel_log_rats)
class(lograt_pca)
lograt_pca$sdev # Explore components of prcomp output

# Visual representation - screeplot
lograt_variances <- as.data.frame(lograt_pca$sdev^2/sum(lograt_pca$sdev^2)) %>% #Extract axes
  # Format to plot
  select(PercVar = 'lograt_pca$sdev^2/sum(lograt_pca$sdev^2)') %>% 
  rownames_to_column(var = "PCaxis") %>% 
  data.frame

# Plot screeplot
ggplot(lograt_variances, aes(x = as.numeric(PCaxis), y = PercVar)) + 
  geom_bar(stat = "identity", fill = "grey", color = "black") +
  theme_minimal() +
  theme(axis.title = element_text(color = "black", face = "bold", size = 10),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.text.x = element_blank()) +
  labs(x = "PC axis", y = "% Variance", title = "Log-Ratio PCA Screeplot")
## We conclude a more faithful representation is to plot this ordination in 2D because the 3rd and 4th axes appear very similar, and we can't construct a 4D plot

#
# Using the Screeplot as a diagnostic tool
#
# Example of how we would make other decisions # Fake data alert
z <- data.frame(var_3d = c(0.14, 0.11382161, 0.099, 0.04150648, 0.04003648, 0.04003648, 0.03973198, 0.03945737, 0.03945737, 0.0390119, 0.03828896, 0.03758661, 0.03758661, 0.03717911, 0.03690672, 0.03690672, 0.03601781, 0.03601781, 0.03592505, 0.03552493), var_2d = c(0.14534255, 0.1, 0.05089299, 0.04996212, 0.04930953, 0.04879017, 0.04879017, 0.04879017, 0.0454934, 0.0454934, 0.0454934, 0.04524461, 0.0407007, 0.03982556, 0.03982556, 0.03973198, 0.03971273, 0.03971273, 0.03758661, 0.03688823))
z$pcaxis <- as.numeric(row.names(z))

plot_grid(
  ggplot(z, aes(x = pcaxis, y = var_3d)) + 
  geom_bar(stat = "identity", fill = "grey", color = "black") +
  theme_minimal() +
  theme(axis.title = element_text(color = "black", face = "bold", size = 10),
        title = element_text(color = "black", face = "bold", size = 8),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.text.x = element_blank()) +
  labs(x = "PC axis", y = "% Variance", title = "Example - 3 axies would be most appropriate\nLog-Ratio PCA Screeplot"),
  ggplot(z, aes(x = pcaxis, y = var_2d)) + 
    geom_bar(stat = "identity", fill = "grey", color = "black") +
    theme_minimal() +
    theme(axis.title = element_text(color = "black", face = "bold", size = 10),
          title = element_text(color = "black", face = "bold", size = 8),
          axis.text.y = element_text(color = "black", face = "bold"),
          axis.text.x = element_blank()) +
    labs(x = "PC axis", y = "% Variance", title = "Example - 2 axies would be most appropriate\nLog-Ratio PCA Screeplot"), ncol = 1
  )

# Use the screeplot as a diagnostic tool

#
# Visualize the PCA
# lograt_pca$
lograt_pca$x #View PC values
pca_lograt_frame <- data.frame(lograt_pca$x) %>% 
  rownames_to_column(var = "TimeofDay") %>% 
  separate(TimeofDay, into = c("excess", "TimeofDay"), sep = "_") %>% 
  select(-excess) %>% 
  data.frame
head(pca_lograt_frame)

# Plot PCA
ggplot(pca_lograt_frame) +
  geom_point(aes(x = PC1, y = PC2, fill = TimeofDay), size = 4, shape = 21, color = "black") +
  ylab(paste0('PC2 ', round(lograt_variances[2,2]*100,2),'%')) + #Extract y axis value from variance
  xlab(paste0('PC1 ', round(lograt_variances[1,2]*100,2),'%')) + #Extract x axis value from variance
  scale_fill_brewer(palette = 'Dark2', name = 'Time of Day') +
  ggtitle('Log-Ratio PCA Ordination') +
  coord_fixed(ratio = 1) +
  theme_bw()

#
# PCoA
#
# PCoA is doing a PCA on a distance matrix constructed from the data. 
# We then need a distance matrix. 
# Different distance metrics emphasize separate attributes/factors in microbial community comparison

# For instance, if we want to prioritize differences in presence/absence between samples - use Jaccard. This can be estimated from untransformed count data, and does a pretty good job considering rare taxa. Another is unweighted Unifrac that includes phylogenetic relatedness (see last week's lesson).
jac_dmat<-vegdist(t(diel_qced),method="jaccard") # Jaccard dist metric
pcoa_jac<-pcoa(jac_dmat) #perform PCoA
# jac_dmat = jaccard dissimilarity index of data
# pcoa_jac = PCoA result

# Again, we will use the screeplot approach to see how the PCoA turned out.

# Extract variances from pcoa, from jaccard calculated dist. metric
jac_variances <- data.frame(pcoa_jac$values$Relative_eig) %>% 
  select(PercVar = 'pcoa_jac.values.Relative_eig') %>% 
  rownames_to_column(var = "PCaxis") %>% 
  data.frame
head(jac_variances)

# Screeplot check
ggplot(jac_variances, aes(x = as.numeric(PCaxis), y = PercVar)) + 
  geom_bar(stat = "identity", fill = "grey", color = "black") +
  theme_minimal() +
  theme(axis.title = element_text(color = "black", face = "bold", size = 10),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.text.x = element_blank()) +
  labs(x = "PC axis", y = "% Variance", title = "Log-Ratio PCoA Screeplot")

# How to read this plot: Before we plot the actual ordination, we need to decide which axes to present. We need to select as few axes as possible (so we can visualize) which capture large amounts of variance. In this example, we see the first axis captures most of the variance, so we definitely will show that one. Then the next two axes show less, but a similar amount, and the remaining all show way less in comparison. Therefore, we can exclude everything after the 3rd axis. Because axes 2 and 3 capture similar amounts of variance, if we show one, we need to show the other one to be faithful to the data.
## Most appropriate to show this data in 3-D

#
# Plot in 3-D with plotly
#
# Extract variances from pcoa, from jaccard calculated dist. metric
## where samples fall among axes
pcoa_jac_df <- data.frame(pcoa_jac$vectors) %>% 
  rownames_to_column(var = "TimeofDay") %>% 
  separate(TimeofDay, into = c("excess", "TimeofDay"), sep = "_") %>% 
  select(-excess) %>% 
  data.frame
head(pcoa_jac_df)

# Select eigen values from dataframe, round to 4 places. These will be the axes for the 3-D plot
# Extract variances from previously generated dataframe, round and multiply by 100 for plotting
eigenvalues<-round(jac_variances[,2], digits = 4)*100
# Plotly - 3-D
plot_ly(pcoa_jac_df, type='scatter3d', mode='markers',
        x=~Axis.2,y=~Axis.3,z=~Axis.1,colors=~brewer.pal(6,'Set1'),color=~TimeofDay)%>%
  layout(font=list(size=18),
         title='PCoA Jaccard Distance',
         scene=list(xaxis=list(title=paste0('Co 2 ',eigenvalues[2],'%'),
                               showticklabels=FALSE,zerolinecolor='black'),
                    yaxis=list(title=paste0('Co 3 ',eigenvalues[3],'%'),
                               showticklabels=FALSE,zerolinecolor='black'),
                    zaxis=list(title=paste0('Co 1 ',eigenvalues[1],'%'),
                               showticklabels=FALSE,zerolinecolor='black')))

# Performing the log-ratio transformation makes the data all occupy a similar dynamic range, so we can use magnitude-sensitive distances like euclidean distance



#
# Compare to another transformation
#

# Take ilr transformed data and estimate euclidean distince.
# diel_log_rats <- data.frame(compositions::ilr(t(diel_qced))) # From above
euc_dmat<-dist(diel_log_rats, method = "euclidean") 
# Euclidean, recommended for analysis of the difference in compositions. e.g., when we are working to understand changes in relative abundance. Because it depends on the composition, we must input transformed data.

## Conduct ordination w/distance matrix = PCoA
pcoa_euc<-ape::pcoa(euc_dmat)

# Extract variances from pcoa, from jaccard calculated dist. metric
euc_variances <- data.frame(pcoa_euc$values$Relative_eig) %>% 
  select(PercVar = 'pcoa_euc.values.Relative_eig') %>% 
  rownames_to_column(var = "PCaxis") %>% 
  data.frame
head(euc_variances)

# Screeplot check
ggplot(euc_variances, aes(x = as.numeric(PCaxis), y = PercVar)) + 
  geom_bar(stat = "identity", fill = "grey", color = "black") +
  theme_minimal() +
  theme(axis.title = element_text(color = "black", face = "bold", size = 10),
        axis.text.y = element_text(color = "black", face = "bold"),
        axis.text.x = element_blank()) +
  labs(x = "PC axis", y = "% Variance", title = "Euclidean\nLog-Ratio PCoA Screeplot")

# By trying 2 different metrics, we see a differences in ordination output.
# Recall, for the Jaccard distance, we need 3 axes to present the ordination. 
# Here, using euclidean distance, because of the complex covariance structure of the relative compositions, the data do not easily ordinate into 2 or 3 dimensions.

# We can repeat this in 3 dimensions also:
pcoa_euc_df <- data.frame(pcoa_euc$vectors) %>% 
  rownames_to_column(var = "TimeofDay") %>% 
  separate(TimeofDay, into = c("excess", "TimeofDay"), sep = "_") %>% 
  select(-excess) %>% 
  data.frame
head(pcoa_euc_df)

# Select eigen values from dataframe, round to 4 places. These will be the axes for the 3-D plot
# Extract variances from previously generated dataframe, round and multiply by 100 for plotting
eigenvalues<-round(euc_variances[,2], digits = 4)*100
# Plotly - 3-D
plot_ly(pcoa_euc_df, type='scatter3d', mode='markers',
        x=~Axis.2,y=~Axis.3,z=~Axis.1,colors=~brewer.pal(6,'Set1'),color=~TimeofDay)%>%
  layout(font=list(size=18),
         title='PCoA Jaccard Distance',
         scene=list(xaxis=list(title=paste0('Co 2 ',eigenvalues[2],'%'),
                               showticklabels=FALSE,zerolinecolor='black'),
                    yaxis=list(title=paste0('Co 3 ',eigenvalues[3],'%'),
                               showticklabels=FALSE,zerolinecolor='black'),
                    zaxis=list(title=paste0('Co 1 ',eigenvalues[1],'%'),
                               showticklabels=FALSE,zerolinecolor='black')))

## To compare with the euclidean distance ordination representing differences in relative composition
## Further note: If your ordination has data which align in a 'T' or '+' shape perpendicular to the axes
## this is often diagnostic of covariance attributed to the higher dimensions which are not plotted


# Although our statistical ordinations appear to require at least 3 dimensions to communicate the data.
# However, we don't always have the budget for a 3D plot. So we may want to impose the condition on an ordination
# technique that the answer MUST go in 2D. We turn to NMDS here. 
#
set.seed(071510) # setting random seed to assure NMDS comes out the same every time

## So we can compare the relative composition based distance metric to the presence/absence based distance metric
# ?metaMDS() #vegan package, NMDS  
# NMDS: force data into a desired number of dimensions, works to preserve all pairwise distances between points.

# euc_dmat<-dist(diel_log_rats, method = "euclidean") # From above
euc_nmds<-metaMDS(euc_dmat,k=2,autotransform=FALSE)
# jac_dmat<-vegdist(t(diel_qced),method="jaccard") # From above
jac_nmds<-metaMDS(jac_dmat,k=2,autotransform=FALSE)

# Take a look at stress - overall this value is not extremely informative, but know that the
# closer stress is to 1 the less representative of your actual data the NMDS is.
euc_nmds$stress #Stress ~0.059
jac_nmds$stress #Stress ~0.067 

# Additionally, the axes for NMDS are totally arbitrary, so axis scaling does not matter
# and data can be rotated/reflected about axes and the NMDS is still the same

euc_nmds$points #Extract points from NMDS

euc_frame <- data.frame(euc_nmds$points) %>% 
  rownames_to_column(var = "TimeofDay") %>% 
  separate(TimeofDay, into = c("excess", "TimeofDay"), sep = "_") %>% 
  select(-excess) %>% 
  data.frame
 
## Plotting euclidean distance NMDS
ggplot(euc_frame,aes(x = MDS1, y = MDS2, fill = TimeofDay)) +
  geom_point(size = 4, shape = 21, color = "black", aes(fill = TimeofDay)) +
  scale_fill_brewer(palette = "Dark2") +
  theme_bw() +
  labs(x = "NMDS 1", y = "NMDS 2", title = "Euclidean Distance NMDS")
  
#
# END
#


# Things we did not cover, but you need to think about before performing this on your data.
## What to do with zeroes? what do they mean in your data? how should you handle them?
## Outliers! explore them, explain them
