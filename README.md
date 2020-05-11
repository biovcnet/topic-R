# TOPIC: R
A repository for the lessons and tutorials for the R TOPIC channel of the [BVCN](https://biovcnet.github.io/).   
Each week we will debut a new lesson with a video tutorial and a set time for a live demonstration. Additionally, we will work to hold **R Office** hours each week to review the material, go into more detail on what we've learned, and try to answer any questions you may have.

For a full list of resources also see the [R topic BVCN Wiki page](https://github.com/biovcnet/biovcnet.github.io/wiki/TOPIC:-R).

## Prerequisites
* Access to browser window, RStudio Cloud account
* (_Optional_)[Experience with the command line](https://github.com/biovcnet/biovcnet.github.io/wiki/2.-Using-the-Command-line)

# Overview
This BVCN topic will cover:

* the fundamentals of coding in the R language
* methods for importing data to R and data wrangling
* methods for data analysis
* troubleshooting your own R code
* how to generate graphs or figures in R
* the use of R in the context of analyzing commonly encountered data types (e.g., amplicon sequence results, differential expression, etc.)


# Lesson 1
### Title: Introduction to R & Connect to RStudio Cloud
_Instructors_: Sarah Hu, Liz Suter, Alexis Marshall    

Goals:
* Introduce the R language
* [Connect to RStudio Cloud](https://rstudio.cloud)
* Copy and move your first R lesson to your RStudio Cloud workspace
* Learn basic operators and R syntax   

## **Lesson 1 agenda**
**Ahead of time**
1. Sign up with a free [RStudio Cloud](https://rstudio.cloud) account
2. Find the provided link from Slack or the introduction email to grant you access to the BVCN R lesson workspace in RStudio.
3. Watch this tutorial intro to RStudio and how we will navigate lessons [Link to YouTube video](https://youtu.be/kicRl5UNE64)    

**Live lesson**
4. Review RStudio navigation and what was covered in the tutorial video
5. Work through basic functions in the *Lesson01* R project  


[Link to live Lesson 1 recording](https://www.youtube.com/watch?v=u6vgWyD351g)
 

**_Orientation in RStudio Cloud_**
* _Workspaces_: This is your own personal workspace or “sandbox”. You can make them private or public. The BVCN lessons will be listed each week in the BVCN-R workspace.
* _Projects_: This is a list of R Projects that you can open in RStudio Cloud. Each week, you can copy the lessons from the shared BCVN Workspace to your personal list of projects
* To execute a command from an R script (which will be sent to the Rconsole), on a **Mac**: press COMMAND+ENTER and on a **PC** it is CTRL+ENTER

**What is RStudio Cloud?**
RStudio itself is also an application that can be installed on your computer that is an easy to use interface for writing and executing R code. RStudio Cloud is a cloud-based platform to run RStudio. It circumvents the installation of R on your local computer, to minimize any issues and frustrations that may arise when learning and accessing R remotely. Another reason we are using Rstudio Cloud is that it will be a streamlined way for us to share code with you as we venture into learning the R language.

***

# Lesson 2
### Title: Dealing with data frames
**Instructors**: Ella Sieradzki

[Link to live lesson](https://www.youtube.com/watch?v=_rep0HhPA-Y&feature=youtu.be)

Goal: In this lesson we'll see how to manipulate tables in R just like you would in Excel. We will learn how to sort a table, filter it, transpose it, change column names and merge it with another table.   

**Agenda**
* View this recorded lecture for lesson-02 [Link to Youtube recording](https://youtu.be/qWjo_o9QJBI)
* Basic data table manipulation
* Import test data into R from .csv format
* Applying basic mathematical functions to a data table
* Merge data table together

_Take home messages_
* In Excel you are working on a single document and modifying it, while in R, the best practice when transforming data is to create a new object in R. This way you have traces of your previous table. This allows for a more reproducible product and reduces those errors that happen when you copy and paste cells in Excel.

***

# Lesson 3
### Title: Introduction to Tidyverse
**Instructors**: Sarah Hu

[Link to live lesson](https://www.youtube.com/watch?v=_VVdPsnTrO4&feature=youtu.be)

Goal: Continue learning how to manipulate data frames in R, but use the functions and syntax available through tidyverse.   

**Agenda**
* View the recorded lecture for lesson-03 [Link to Youtube recording](https://www.youtube.com/watch?v=Oj0yRXrvm2Q&feature=youtu.be)
* Overview of data frames, matrices, and tibbles
* Change column headers and reorder columns in base R
* Repeat column renaming and reorder in tidyverse
* Subset and filter data in base R, repeat in tidyverse
* Wide vs. long format data
* Separating (parsing) column header into multiple columns
* Introduce ```mutate()``` and ```summarise()``` to calculate averages and relative abundance

***

# Lesson 4
### Title: Dealing with NAs in your data
**Instructors**: Philip Leftwich

Goal: Techniques and tools for dealing with NAs in your data set. And how to find them!

[Link to live lesson](https://www.youtube.com/watch?v=iTS5OEqt6M8)


***


# Lesson 5
### Title: Introduction to plotting
**Instructors**: Ella Sieradzki

[Link to live lesson](https://www.youtube.com/watch?v=uv972TDRflI)

Goal: Learn how to plot an XY scatter in base R and ggplot2 and become familiar with graphic parameters

**Agenda**
* Simple plotting of the Iris dataset
* Color points by series/group
* Adding margins and placing the legend outside of the plot
* par - the hub of graphic parameters
* Trendlines
