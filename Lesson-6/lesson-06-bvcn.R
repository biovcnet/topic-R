library(tidyverse)

head(starwars)

# Addressing things brought up in the R slack thread:
# - Network analysis channel! check it out.
# - visualizing ordination (pcoa) - next! basic stats required!
# - single chart with 2 y-axes. No-go in tidyverse... check out base R plotting

# Bar charts vs. box plots
## How do we make them? When are they appropriate?

# Star Wars data- we want to know more about the droids and humans that live on Tatooine.

# First what is the data I'm looking at on Tatooine
View(starwars)
tatooine <- starwars %>% 
  filter(homeworld == "Tatooine") %>% 
  data.frame

# How many species on Tatooine?

# Bar chart example
## First, example that has something wrong with it:
ggplot(tatooine, aes(x = species, y = height)) +
  geom_bar(stat = "identity")
# What's wrong with this?

# A better use of bar chart, but addresses a different question
ggplot(tatooine, aes(x = species)) +
  geom_bar(stat = "count")


# Let's add aesthetics and set it equal to a variable
bar_num_species <- ggplot(tatooine, aes(x = species)) +
  geom_bar(stat = "count", width = 0.4, color = "black", fill = "orange") +
  theme_bw() +
  labs(x = "Species on Tatooine", y = "Total number of species")
bar_num_species

# Box plot example
## Let's address that question now, but with a better graphical representation
ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot()

ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot() +
  geom_point()

ggplot(tatooine, aes(x = species, y = height)) +
  geom_boxplot() +
  geom_jitter()

# Repeat with mass now:
ggplot(tatooine, aes(x = species, y = mass)) +
  geom_boxplot() +
  geom_jitter()
# What's with warning?

##Quick example of combining all the tidyverse!
# filter(starwars, homeworld == "Tatooine") %>%
  # ggplot(aes(x = species, y = mass)) +
  # geom_jitter() +
  # geom_boxplot()


# Recall when I mentioned I prefer long format over wide format?
## Let's explore that..

# Subset species from Tatooine
colnames(starwars)
starwars_long <- starwars %>%
  select(name, height, mass, homeworld, species) %>%
  filter(homeworld == "Tatooine") %>%
  pivot_longer(cols = height:mass, names_to = "MEASUREMENT", values_to = "VALUE") %>%
  data.frame
# head(starwars_long)

# Now we can plot BOTH measurements (height and mass) using "facet_grid()"
ggplot(starwars_long, aes(x = species, y = VALUE)) +
  geom_jitter() +
  geom_boxplot() +
  facet_grid(. ~ MEASUREMENT)

# Let's improve the aesthetics and then combine with our other plot
# theme
# x and y labels
# colors for droids and humans

ggplot(starwars_long, aes(x = species, y = VALUE)) +
  geom_jitter() +
  geom_boxplot() +
  facet_grid(. ~ MEASUREMENT)

ggplot(starwars_long, aes(x = species)) +
  geom_bar(stat = "count")

# Combining plots together
library(cowplot)


# The taxonomy barplot
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

supergroup <- asv_long %>%
  group_by(SAMPLE, Vent, Year, Supergroup) %>%
  filter(!is.na(Supergroup)) %>%
  summarise(SUM = sum(COUNT)) %>%
  data.frame

head(supergroup)

# Stacked
ggplot(supergroup, aes(x = SAMPLE, y = SUM, fill = Supergroup)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid(. ~ Year, scales = "free") +
  theme(axis.text.x = element_text(angle = 90))

ggplot(supergroup, aes(x = SAMPLE, y = SUM, fill = Supergroup)) +
  geom_bar(stat = "identity", position = "fill") +
  facet_grid(. ~ Year, scales = "free") +
  theme(axis.text.x = element_text(angle = 90))

