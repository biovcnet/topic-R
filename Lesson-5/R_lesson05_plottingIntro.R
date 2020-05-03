# Scatter plots in base R and ggplot2

data(iris)
head(iris)

# Base R - scatter plot
plot(iris$Petal.Length, iris$Sepal.Length)

# You can define everything from column labels through shape and color of the dots
plot(iris$Petal.Length, iris$Sepal.Length, xlab="Petal Length", ylab="Sepal Length", main="Iris sepal as a function of petal", col="purple", pch=3)
# Google R pch for shape options!

# What if you want each species in a different color?
plot(iris$Petal.Length, iris$Sepal.Length, xlab="Petal Length", ylab="Sepal Length", main="Iris sepal as a function of petal", col=iris$Species, pch=3)
legend("topleft", legend = levels(iris$Species), col = 1:3, cex = 0.8, pch = 3)
# type palette() in the console to see the default colors R uses when you assign a factor to col

# Change the color palette with RColorBrewer
# install.packages("RColorBrewer")
library(RColorBrewer)
display.brewer.all()
# The same function palette() can also set the color palette you want to use
palette(brewer.pal(n = 3, name = "Dark2"))
plot(iris$Petal.Length, iris$Sepal.Length, xlab="Petal Length", ylab="Sepal Length", main="Iris sepal as a function of petal", col=iris$Species, pch=3)
legend("topleft", legend = levels(iris$Species), col = 1:3, cex = 0.8, pch = 3)
# RColorBrewer has color schemes suitable for color blindness

# Want to set your own color choices? Use hexadecimal code? Sure thing!
palette(c("#821273", "#128230", "#825112"))
plot(iris$Petal.Length, iris$Sepal.Length, xlab="Petal Length", ylab="Sepal Length", main="Iris sepal as a function of petal", col=iris$Species, pch=20)
legend("topleft", legend = levels(iris$Species), col = 1:3, cex = 0.8, pch = 20)
# Check out https://www.sessions.edu/color-calculator/ to find color schemes depending on the number of groups

# Changing the size of the points 
plot(iris$Petal.Length, iris$Sepal.Length, xlab="Petal Length", ylab="Sepal Length", main="Iris sepal as a function of petal", col=iris$Species, pch=20, cex=0.8)
legend("topleft", legend = levels(iris$Species), col = 1:3, cex = 0.8, pch = 20)

# Adding margins - c(bottom, left, top, right)
par(mar=c(6,5,5,10))
# To allow the legend to be outside of the plot
par(xpd=TRUE)
plot(iris$Petal.Length, iris$Sepal.Length, xlab="Petal Length", ylab="Sepal Length", main="Iris sepal as a function of petal", col=iris$Species, pch=20, cex=0.8)
legend(7.2, 8, legend = levels(iris$Species), col = 1:3, cex = 0.8, pch = 20)

# Explore ?par() to see dozens of graphic parameters you can set in your plot

# Add trendlines with linear models
par(xpd=FALSE)
fit <- lm(iris$Sepal.Length~iris$Petal.Length)
summary(fit)
co <- coef(fit)

# abline draws a line defined by a formula, in this case ax+b (defined by the linear model coefficients)
abline(co, col="blue", lwd=2)
# You can also add a vertical line or a horizontal line
abline(v=2.2, col="grey", lwd=3)
abline(h=7.05, col="black", lwd=1)


# How to do all of this in ggplot2

library("tidyverse")
# First we create the base of the plot by providing the data and the grouping variable if you have one
p <- ggplot(data=iris, aes(y=Sepal.Length, x=Petal.Length))
# Now you can set graphics however you like! You can also keep adding parameters with the operator +
p + geom_point()
# Change points color by grouping variable Species
p + geom_point(aes(colour=factor(Species)))
# Set your own colors
p + geom_point(aes(colour=factor(Species))) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"))
# You can also use other color palettes with scale_color_discrete
p + geom_point(aes(colour=factor(Species))) + 
  scale_colour_brewer(palette="Dark2")
# Change the size of the points - note that for a constant size the parameter has to be OUTSIDE of aes()
p + geom_point(aes(colour=factor(Species)), size=2) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"))
# Change the size of the points to depend on a variable, so it has to be INSIDE of aes()
p + geom_point(aes(colour=factor(Species), size=Petal.Width)) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"))
# Change the theme of the plot
p + geom_point(aes(colour=factor(Species), size=2)) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a")) +
  theme_classic()
# Change the shape of the points
p + geom_point(aes(colour=factor(Species)), shape=12, size=3) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a")) +
  theme_dark()
# If you type theme_ and then hit Tab you'll get all options for different themes. Try them out!
# Change the shape of the points by a grouping variable
p + geom_point(aes(colour=factor(Species), shape=Species)) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a")) +
  theme_classic()
# If you had another grouping variable you could use it to set shapes instead of using Species again
tmp <- iris
tmp$new_grp <- sample(x = c(1, 2, 3), size = nrow(tmp), replace = TRUE)
p <- ggplot(data=tmp, aes(y=Sepal.Length, x=Petal.Length))
p + geom_point(aes(colour=factor(Species), shape=factor(new_grp))) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a")) +
  theme_classic()
# Set axis labels
p + geom_point(aes(colour=factor(Species), shape=factor(new_grp))) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a")) +
  theme_classic() +
  xlab("Petal Length") +
  ylab("Sepal Length") +
  ggtitle("Iris sepal as a function of petal")
# Or you could just use the function labs() to set all three and center the title with hjust
# hjust gets a number from 0 to 1. 0 means left-aligned and 1 means right aligned, so 0.5 means centered.
p + geom_point(aes(colour=factor(Species))) + 
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a")) +
  theme_classic() +
  labs(title="Iris sepal as a function of petal", x="Petal Length", y="Sepal Length") +
  theme(plot.title = element_text(hjust = 0.5))
# Change legend title and labels
p + geom_point(aes(colour=factor(Species))) + 
  theme_classic() +
  labs(title="Iris sepal as a function of petal", x="Petal Length", y="Sepal Length") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"), 
                    name="Species",
                    breaks=c("setosa", "versicolor", "virginica"),
                    labels=c("Setosa", "Versicolor", "Virginica"))
# ggplot2 has its own version of abline that also calculates the model
p + geom_point(aes(colour=factor(Species))) + 
  theme_classic() +
  labs(title="Iris sepal as a function of petal", x="Petal Length", y="Sepal Length") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"), 
                      name="Species",
                      breaks=c("setosa", "versicolor", "virginica"),
                      labels=c("Setosa", "Versicolor", "Virginica")) +
  geom_smooth(method = "lm", se = FALSE)
# Check out geom_hline and geom_vline that match abline(h=) and abline(v=)
# Add a 95% confidence interval
p + geom_point(aes(colour=factor(Species))) + 
  theme_classic() +
  labs(title="Iris sepal as a function of petal", x="Petal Length", y="Sepal Length") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"), 
                      name="Species",
                      breaks=c("setosa", "versicolor", "virginica"),
                      labels=c("Setosa", "Versicolor", "Virginica")) +
  geom_smooth(method = "lm", se = TRUE)
# Add a 90% confidence interval
p + geom_point(aes(colour=factor(Species))) + 
  theme_classic() +
  labs(title="Iris sepal as a function of petal", x="Petal Length", y="Sepal Length") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"), 
                      name="Species",
                      breaks=c("setosa", "versicolor", "virginica"),
                      labels=c("Setosa", "Versicolor", "Virginica")) +
  geom_smooth(method = "lm", se = TRUE, level=0.9)
# Create a trendline for each species by defining colour within the original plot - this grouping is now inherited downstream
p <- ggplot(data=tmp, aes(y=Sepal.Length, x=Petal.Length, colour=Species))
p + geom_point(aes(colour=factor(Species))) + 
  theme_classic() +
  labs(title="Iris sepal as a function of petal", x="Petal Length", y="Sepal Length") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_colour_manual(values=c("#1f78b4", "#a6cee3", "#6a3d9a"), 
                      name="Species",
                      breaks=c("setosa", "versicolor", "virginica"),
                      labels=c("Setosa", "Versicolor", "Virginica")) +
  geom_smooth(method = "lm", se = TRUE, level=0.99)
