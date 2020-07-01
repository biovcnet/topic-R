library(tidyverse)
library(RColorBrewer)
# library(cowplot)
library(patchwork)

head(starwars)

# Addressing things brought up in the R slack thread:
# - Network analysis channel! check it out.
# - visualizing ordination (pcoa) - next! basic stats required!
# - single chart with 2 y-axes. No-go in tidyverse... check out base R plotting

# Bar charts vs. box plots
## How do we make them? When are they appropriate?

# Star Wars data- we want to know more about the droids and humans that live on Tatooine (height and mass)

# First what is the data I'm looking at on Tatooine
View(starwars)

tatooine <- starwars %>% 
  filter(homeworld == "Tatooine") %>% # select only those from Tatooine
  data.frame

# How many species on Tatooine?
unique(starwars$species); length(unique(starwars$species))
unique(tatooine$species); length(unique(tatooine$species))

# Bar chart example
## First, example of a bar chart **but something isn't right**
ggplot(tatooine, aes(x = species, y = height)) +
  geom_bar(stat = "identity")
  
# What's wrong with this?
starwars %>% 
  filter(homeworld == "Tatooine") %>%
  group_by(species, homeworld) %>%
  summarise(MEAN_height = mean(height), MEDIAN_height = median(height),
            MAX_height = max(height), MIN_height = min(height),
            MEAN_mass = mean(mass), MEDIAN_mass = median(mass))

hist((filter(tatooine, species == "Human"))$height)  

hist((filter(tatooine, species == "Droid"))$mass)  

# A better way to show this data is via box plot!
## Let's address that question now, but with a better graphical representation
ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot()

## Boxplots in ggplot:
#  median at middle
#  upper/lower hinges = 1st and 3rd quartiles (25th and 75th percentiles)
#  whiskers = largest/lowest value, but maxes at 1.5 * inter-quartile range (distance from upper/lower hinges)
# Outliers are shown as points
# NOTE: varies from base R 'boxplot()'

ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot() +
  geom_point()

ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot() +
  geom_jitter()

ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot() + #notch = TRUE, varwidth = TRUE, fill = "", color = ""
  geom_jitter()

# Repeat with mass now:
ggplot(tatooine, aes(x = species, y = mass)) +
  geom_boxplot() +
  geom_jitter()
# What's with the warning?


## Quick example of combining all the tidyverse!
filter(starwars, homeworld == "Tatooine") %>%
  ggplot(aes(x = species, y = mass)) +
  geom_jitter() +
  geom_boxplot()

## Back to the bar plot example
# This breaks down the species count for 
ggplot(tatooine, aes(x = species)) +
  geom_bar(stat = "count")

# Let's add aesthetics and set it equal to a variable
bar_num_species <- ggplot(tatooine, aes(x = species)) +
  geom_bar(stat = "count", width = 0.4, color = "black", fill = "orange") +
  # Note different in color vs. fill with ggplot
  theme_bw() + # always google themes!
  labs(x = "Species", y = "Total number found on Tatooine") +
  theme(axis.text.x = element_text(face = "bold", color = "black"))
bar_num_species

# Recall when I mentioned I prefer long format over wide format?
## Let's explore that with lots of tidyverse data wrangling and then plot everything
colnames(starwars)

starwars_long <- starwars %>%
  select(name, height, mass, homeworld, species) %>% # select columns that I want
  filter(homeworld == "Tatooine") %>% # grab only species from tatooine
  pivot_longer(cols = height:mass, names_to = "MEASUREMENT", values_to = "VALUE") %>% # wrangle to long format
  data.frame
head(starwars_long)

# Now we can plot BOTH measurements (height and mass) using "facet_grid()"
ggplot(starwars_long, aes(x = species, y = VALUE)) +
  geom_jitter() +
  geom_boxplot() +
  facet_grid(. ~ MEASUREMENT)

# Let's improve the aesthetics and then combine with our other plot
# theme
# x and y labels
# colors for droids and humans

# Factor colors:
species_order <- c("Human", "Droid")
species_color <- c("#c51b8a", "#31a354")
starwars_long$SPECIES_ORDER <- factor(starwards_long$species, levels = species_order)
names(species_color) <- species_order
#
height_mass <- ggplot(starwars_long, aes(x = species, y = VALUE)) +
  geom_jitter() +
  geom_boxplot(aes(fill = species), color = "black") +
  scale_fill_manual(values = species_color) +
  facet_grid(. ~ MEASUREMENT) + # Play with this
  labs(x = "Species", y = "Value") +
  theme_bw() +
  theme(axis.text = element_text(color = "black"),
        strip.background = element_blank(),
        legend.position = "none")
height_mass
height_mass %+% subset(starwars_long, species %in% "Human")
height_mass %+% subset(starwars_long, species %in% "Droid")

count <- ggplot(starwars_long, aes(x = species)) +
  geom_bar(stat = "count", aes(fill = species), color = "black") +
  scale_fill_manual(values = species_color) +
  labs(x = "Species", y = "Count") +
  theme_bw() +
  theme(axis.text = element_text(color = "black"),
        strip.background = element_blank(),
        legend.position = "none")

# Combining plots together
# library(cowplot)
library(patchwork)
height_mass + count
height_mass | count
plot <- height_mass / count
plot + plot_annotation(tag_levels = 'A')


####
## The taxonomy barplot
asv_table <- read.delim("test-axial-asvs.txt", sep = "\t")
View(asv_table) # Check out overall structure
colnames(asv_table) # Sample names

length(asv_table$Feature.ID) # ASVs
length(asv_table$Taxon) # Taxonomy names for ASVs

# Remember how much I love long format data?
asv_long <- asv_table %>%
  pivot_longer(cols = Axial_Anemone_FS891_2013:Axial_Skadi_FS910_2014, names_to = "SAMPLE", values_to = "COUNT") %>%
  filter(COUNT > 0) %>%
  separate(SAMPLE, c("Location", "Vent", "VentID", "Year"), sep = "_", remove = FALSE) %>%
  separate(Taxon, c("Domain", "Supergroup", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ";", remove = FALSE) %>%
  data.frame

head(asv_long)

# Summarize to supergroup level
supergroup <- asv_long %>%
  group_by(SAMPLE, Vent, Year, Supergroup) %>%
  filter(!is.na(Supergroup) & Year == "2013") %>%
  summarise(SUM = sum(COUNT)) %>%
  data.frame

head(supergroup)

# Stacked
ggplot(supergroup, aes(x = SAMPLE, y = SUM, fill = Supergroup)) +
  geom_bar(stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(angle = 90))

# Make it look better
# Factor - see example from above on how to add colors to the Supergroup level
# https://stackoverflow.com/questions/7263849/what-do-hjust-and-vjust-do-when-making-a-plot-using-ggplot
# library(RColorBrewer)

ggplot(supergroup, aes(x = SAMPLE, y = SUM, fill = Supergroup)) +
  geom_bar(stat = "identity", position = "fill", color = "black") +
  scale_fill_brewer(palette = "Dark2") +
  labs(x = "", y = "Relative abundance") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))

