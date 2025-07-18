## Load the dataset
data <- read.csv("garments_worker_productivity.csv")
# This imports the dataset for analysis.

## Understanding the dataset - summary 
summary(data)
# This gives a quick overview of all the columns and their statistics.


## EDA
library(ggplot2)
library(dplyr)
# These libraries are needed for plotting and data manipulation.

head(data)
# Shows the first few rows to understand the structure.

# 1. Check the distribution of 'actual_productivity'
ggplot(data, aes(x = actual_productivity)) +
  geom_histogram(binwidth = 0.05, fill = "skyblue", color = "black") +
  labs(title = "Histogram of Actual Productivity",
       x = "Actual Productivity", y = "Number of Observations")
# This plot helps us see how productivity scores are spread out.

# 2. Average productivity by department
dept_avg <- data %>%
  group_by(department) %>%
  summarise(mean_productivity = mean(actual_productivity, na.rm = TRUE))
print(dept_avg)
# Here we find the average productivity for each department.

# 3. Boxplot of productivity by day
ggplot(data, aes(x = day, y = actual_productivity)) +
  geom_boxplot(fill = "orange", color = "black") +
  labs(title = "Productivity by Day of the Week",
       x = "Day", y = "Actual Productivity")
# The boxplot lets us compare productivity on different days.

# 4. Scatter plot: Overtime vs. Actual Productivity
ggplot(data, aes(x = over_time, y = actual_productivity)) +
  geom_point(alpha = 0.6, color = "purple") +
  labs(title = "Overtime vs. Actual Productivity",
       x = "Overtime", y = "Actual Productivity")
# This plot shows if overtime is related to productivity.

# 5. Check missing values in 'wip'
sum(is.na(data$wip))
# This checks for missing values in the 'wip' column.


## Data manipulation
data$team <- as.numeric(data$team)
data$over_time <- as.numeric(data$over_time)
# Changing these columns to numbers helps with calculation.

data$date <- as.Date(data$date, format = "%m/%d/%Y")
# Converting to date format makes it easier to work with dates.

data$productivity_level <- ifelse(data$actual_productivity >= 0.8, "High", "Low")
table(data$productivity_level)
# Adding a new column lets us label high and low productivity.

data_selected <- data[, c("team", "actual_productivity")]
head(data_selected)
# This makes a smaller table with only team and productivity.

high_overtime <- data[data$over_time > 10000, ]
head(high_overtime[, c("team", "over_time", "actual_productivity")])
# This finds workers who had a lot of overtime.

january_data <- data[months(data$date) == "January", ]
head(january_data[, c("date", "team", "actual_productivity")])
# This filters the data for the month of January.

data_sorted <- data[order(-data$actual_productivity), ]
head(data_sorted[, c("team", "actual_productivity")])
# Sorting helps us see the teams with the highest productivity.


## Data Cleaning
data$wip[is.na(data$wip)] <- mean(data$wip, na.rm = TRUE)
sum(is.na(data$wip))
# Filling missing 'wip' values with the mean keeps the data complete.

data$department <- trimws(tolower(data$department))
data$department[data$department == "sweing"] <- "sewing"
unique(data$department)
# Fixing spelling and spaces keeps department names consistent.

data$team <- as.numeric(data$team)
data$date <- as.Date(data$date)
str(data$team)
str(data$date)
# Making sure columns are the right type helps with calculations.

data <- data[data$actual_productivity <= 1.1, ]
summary(data$actual_productivity)
# Removing outliers gives us more reliable results.


## Statistical Analysis
mean_prod <- mean(data$actual_productivity)
median_prod <- median(data$actual_productivity)
sd_prod <- sd(data$actual_productivity)
mean_prod
median_prod
sd_prod
# These statistics (mean, median, SD) show the typical and spread of productivity.

table(data$department)
# This counts how many records are in each department.

t.test(actual_productivity ~ department, data = data)
# The t-test checks if the average productivity is different between departments.

summary(data[, c("actual_productivity", "over_time", "incentive")])
# This gives a summary of key columns.


## Data Visualisation
# Bar Plot: Average Productivity by Department
dept_avg <- data %>%
  group_by(department) %>%
  summarise(mean_productivity = mean(actual_productivity, na.rm = TRUE))
ggplot(dept_avg, aes(x = department, y = mean_productivity, fill = department)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Productivity by Department",
       x = "Department", 
       y = "Mean Productivity") +
  theme_minimal()
# The bar plot makes it easy to compare departments.

# Correlation Matrix for Numeric Features
library(corrplot)
corrplot(cor_matrix, method = 'color', order = 'alphabet')
# This plot helps us see which numeric variables move together.





