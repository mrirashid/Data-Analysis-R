#i)i. importing the datasets and filtering 2018 Sales Transactions: Total Transaction Count
# Load necessary libraries
library(dplyr)
library(readr)
library(lubridate)
library(tidyr)

# Import all datasets (quietly suppress column spec messages)
sales     <- read_csv("sales.csv", show_col_types = FALSE)
products  <- read_csv("products.csv", show_col_types = FALSE)
inventory <- read_csv("inventory.csv", show_col_types = FALSE)
stores    <- read_csv("stores.csv", show_col_types = FALSE)

# Confirm datasets loaded: print row counts and column names
cat("✅ Datasets loaded successfully.\n\n")

cat("Sales dataset: ", nrow(sales), "rows\n")
cat("Columns: ", paste(colnames(sales), collapse = ", "), "\n\n")

cat("Products dataset: ", nrow(products), "rows\n")
cat("Columns: ", paste(colnames(products), collapse = ", "), "\n\n")

cat("Inventory dataset: ", nrow(inventory), "rows\n")
cat("Columns: ", paste(colnames(inventory), collapse = ", "), "\n\n")

cat("Stores dataset: ", nrow(stores), "rows\n")
cat("Columns: ", paste(colnames(stores), collapse = ", "), "\n\n")

# Filter sales data for transactions in 2018
sales_2018 <- sales %>%
  filter(year(Date) == 2018)

# Count the number of sales transactions in 2018
num_sales_2018 <- nrow(sales_2018)

# Print the result
cat("📆 Number of sales transactions in 2018:", num_sales_2018, "\n\n")

# Optional: Preview the first few filtered records
cat("🔍 Preview of 2018 sales data:\n")
print(head(sales_2018))


#ii)Top Revenue-Generating Product in 2018: Identification and Cross-Dataset Filtering
# Step 1: Convert Product_Price to numeric in products data
products <- products %>%
  mutate(Product_Price = as.numeric(gsub("[^0-9.]", "", Product_Price)))


# Step 2: Join sales with products to get Product_Price
sales_with_price <- sales %>%
  left_join(products, by = "Product_ID")

# Step 3: Calculate revenue for each row (Units * Product_Price)
sales_with_price <- sales_with_price %>%
  mutate(Revenue = Units * Product_Price)

# Step 4: Summarize total revenue by Product_ID
revenue_per_product <- sales_with_price %>%
  group_by(Product_ID) %>%
  summarise(Total_Revenue = sum(Revenue, na.rm = TRUE)) %>%
  arrange(desc(Total_Revenue))

# Step 5: Find Product_ID with highest total revenue
top_product_id <- revenue_per_product %>%
  slice(1) %>%
  pull(Product_ID)

cat("Product_ID with highest total revenue:", top_product_id, "\n")

# Step 6: Get Product_Name from products data
top_product_name <- products %>%
  filter(Product_ID == top_product_id) %>%
  pull(Product_Name)

cat("Product_Name of top Product_ID:", top_product_name, "\n")

# Step 7: Get Store_IDs from inventory where this Product_ID is stocked
store_ids_with_top_product <- inventory %>%
  filter(Product_ID == top_product_id) %>%
  pull(Store_ID)

cat("Store_IDs stocking the top product:\n")
print(unique(store_ids_with_top_product))

#iii) Store Distribution Overview: Cities, Locations, and Product Quantities


# PART A: Count unique cities and distribution locations
num_cities <- stores %>%
  distinct(Store_City) %>%
  nrow()

num_locations <- stores %>%
  distinct(Store_Location) %>%
  nrow()

cat("🏙️ Number of unique cities where stores operate:", num_cities, "\n")
cat("🚛 Number of unique distribution locations:", num_locations, "\n\n")

# PART B: Total quantity of each product distributed in each city
# Join inventory with stores to get Store_City
product_distribution_by_city <- inventory %>%
  left_join(stores, by = "Store_ID") %>%
  group_by(Store_City, Product_ID) %>%
  summarise(Total_Quantity = sum(Stock_On_Hand, na.rm = TRUE), .groups = "drop") %>%
  arrange(Store_City, Product_ID)

# Display first few rows of result
cat("📦 Product distribution by city:\n")
print(head(product_distribution_by_city, 10))  # You can change to n = 20, etc.


# iv) Inventory Summary: Store-Wise Average Quantity Available
# Step iv) Group inventory by Store_ID and calculate average quantity available

# Calculate average quantity available across all products for each store
avg_quantity_by_store <- inventory %>%
  group_by(Store_ID) %>%
  summarise(Average_Quantity_Available = mean(Stock_On_Hand, na.rm = TRUE), .groups = "drop") %>%
  arrange(Average_Quantity_Available)

# Get the store with the lowest average quantity
lowest_avg_store <- avg_quantity_by_store %>%
  slice(1)

# Print full summary
cat("📊 Average quantity available per store:\n")
print(avg_quantity_by_store, n = Inf)  # Display all rows

# Print the lowest average result
cat("\n🏬 Store with the lowest average quantity available:\n")
print(lowest_avg_store)


#v 2018 Monthly Sales and Profit Analysis by Store and City

# Ensure Product_Price and Product_Cost are numeric
products <- products %>%
  mutate(
    Product_Price = as.numeric(gsub("[^0-9.]", "", Product_Price)),
    Product_Cost = as.numeric(gsub("[^0-9.]", "", Product_Cost))
  )

# Step 1: Merge sales with products to get price and cost
sales_with_financials <- sales %>%
  left_join(products, by = "Product_ID") %>%
  mutate(
    Revenue = Units * Product_Price,
    Cost = Units * Product_Cost,
    Profit = Revenue - Cost,
    Month = floor_date(Date, "month")  # Get first day of the month
  )

# Step 2: Merge with store info to get Store_Name, City, Location
sales_full <- sales_with_financials %>%
  left_join(stores, by = "Store_ID")

# Step 3: Total Sales and Profit by Month
monthly_summary <- sales_full %>%
  group_by(Month) %>%
  summarise(
    Total_Sales = sum(Revenue, na.rm = TRUE),
    Total_Profit = sum(Profit, na.rm = TRUE),
    .groups = "drop"
  )

# Print full summary: adjust n to see all rows
cat("\n📅 Monthly Sales & Profit Summary:\n")
print(monthly_summary, n = Inf)  # Display all rows
# Step 4: Store-level total sales and profit
store_summary <- sales_full %>%
  group_by(Store_ID, Store_Name, Store_Location) %>%
  summarise(
    Total_Sales = sum(Revenue, na.rm = TRUE),
    Total_Profit = sum(Profit, na.rm = TRUE),
    .groups = "drop"
  )

# Step 5: City-level total sales and profit
city_summary <- sales_full %>%
  group_by(Store_City) %>%
  summarise(
    Total_Sales = sum(Revenue, na.rm = TRUE),
    Total_Profit = sum(Profit, na.rm = TRUE),
    .groups = "drop"
  )

# Print full summary: adjust n to see all rows
cat("\n🌆 City-Level Total Sales & Profit Summary:\n")
print(city_summary, n = Inf)  # Display all rows

# Step 6: Identify extremes

## Store with highest and lowest sales
top_store_sales <- store_summary %>% arrange(desc(Total_Sales)) %>% slice(1)
bottom_store_sales <- store_summary %>% arrange(Total_Sales) %>% slice(1)

## Store with highest and lowest profit
top_store_profit <- store_summary %>% arrange(desc(Total_Profit)) %>% slice(1)
bottom_store_profit <- store_summary %>% arrange(Total_Profit) %>% slice(1)

## City with highest and lowest sales
top_city_sales <- city_summary %>% arrange(desc(Total_Sales)) %>% slice(1)
bottom_city_sales <- city_summary %>% arrange(Total_Sales) %>% slice(1)

## City with highest and lowest profit
top_city_profit <- city_summary %>% arrange(desc(Total_Profit)) %>% slice(1)
bottom_city_profit <- city_summary %>% arrange(Total_Profit) %>% slice(1)

# Step 7: Print Results

cat("\n📅 Monthly Sales & Profit Summary:\n")
print(monthly_summary, n = Inf)  # Display all rows

cat("\n🏬 Store with Highest Sales:\n")
print(top_store_sales)

cat("\n🏬 Store with Lowest Sales:\n")
print(bottom_store_sales)

cat("\n💰 Store with Highest Profit:\n")
print(top_store_profit)

cat("\n💰 Store with Lowest Profit:\n")
print(bottom_store_profit)

cat("\n🌆 City with Highest Sales:\n")
print(top_city_sales)

cat("\n🌆 City with Lowest Sales:\n")
print(bottom_city_sales)

cat("\n💼 City with Highest Profit:\n")
print(top_city_profit)

cat("\n💼 City with Lowest Profit:\n")
print(bottom_city_profit)

# If you want to display all rows of store summaries, you could add:
cat("\n🏬 Store-Level Total Sales & Profit Summary:\n")
store_summary <- sales_full %>%
  group_by(Store_ID, Store_Name, Store_Location) %>%
  summarise(
    Total_Sales = sum(Revenue, na.rm = TRUE),
    Total_Profit = sum(Profit, na.rm = TRUE),
    .groups = "drop"
  )

print(store_summary, n = Inf)  # Display all rows of store summary

#vi) Descending Product Cost Ranking and Brand Extraction from Product Names

library(tidyr)

# Step 1: Convert Product_Cost to numeric
products_clean <- products %>%
  mutate(Product_Cost = as.numeric(gsub("[^0-9.]", "", Product_Cost)))

# Step 2: Arrange in descending order of Product_Cost
products_sorted <- products_clean %>%
  arrange(desc(Product_Cost))

# Step 3: Separate Product_Name into Product and Brand using hyphen
products_separated <- products_sorted %>%
  separate(Product_Name, into = c("Product", "Brand"), sep = " - ", fill = "right")

# Step 4: Get Brand of third most expensive product
third_product <- products_separated %>% slice(3)

# Step 5: Output result with fallback if Brand is missing
if (is.na(third_product$Brand) || third_product$Brand == "") {
  cat("The third most expensive product does not contain a brand after a hyphen (-).\n")
  cat("Full product name:", third_product$Product, "\n")
} else {
  cat("Brand of the third most expensive product:", third_product$Brand, "\n")
}

#vii)  Price Elasticity of Demand Analysis Using dplyr in R

# Import datasets
sales <- read_csv("sales.csv", show_col_types = FALSE)
products <- read_csv("products.csv", show_col_types = FALSE)

# Step 1: Convert Product_Price to numeric in products data
products <- products %>%
  mutate(Product_Price = as.numeric(gsub("[^0-9.]", "", Product_Price)))

# Step 2: Join sales with products to get Product_Price
sales_with_price <- sales %>%
  left_join(products, by = "Product_ID")

# Step 3: Calculate average price and quantity sold for each product
avg_price_quantity <- sales_with_price %>%
  group_by(Product_ID) %>%
  summarise(
    Avg_UnitPrice = mean(Product_Price, na.rm = TRUE),
    Avg_Quantity = mean(Units, na.rm = TRUE),
    .groups = "drop"
  )

# Step 4: Calculate percentage changes for quantity and price
price_quantity_changes <- avg_price_quantity %>%
  arrange(Product_ID) %>%
  mutate(
    Prev_Avg_UnitPrice = lag(Avg_UnitPrice),
    Prev_Avg_Quantity = lag(Avg_Quantity),
    Price_Change_Percent = (Avg_UnitPrice - Prev_Avg_UnitPrice) / Prev_Avg_UnitPrice * 100,
    Quantity_Change_Percent = (Avg_Quantity - Prev_Avg_Quantity) / Prev_Avg_Quantity * 100
  ) %>%
  filter(!is.na(Price_Change_Percent) & !is.na(Quantity_Change_Percent))

# Step 5: Calculate price elasticity of demand
price_elasticity <- price_quantity_changes %>%
  mutate(Price_Elasticity = Quantity_Change_Percent / Price_Change_Percent)

# Step 6: Identify most and least sensitive products
most_sensitive <- price_elasticity %>%
  arrange(desc(Price_Elasticity)) %>%
  slice(1)

least_sensitive <- price_elasticity %>%
  arrange(Price_Elasticity) %>%
  slice(1)

# Print the results
cat("📈 Most Sensitive Product to Price Changes:\n")
print(most_sensitive)

cat("\n📉 Least Sensitive Product to Price Changes:\n")
print(least_sensitive)

# Discuss implications for pricing strategies
cat("\n💡 Discussion:\n")
cat("The most sensitive product indicates a higher sensitivity to price changes, suggesting that reducing the price may lead to a proportionally larger increase in quantity sold. Conversely, the least sensitive product may not see significant changes in sales volume with price adjustments, indicating that it could potentially sustain higher pricing without a drastic impact on sales.")

