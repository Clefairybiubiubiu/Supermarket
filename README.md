🛒 Supermarket Sales Dataset Analysis
This project analyzes supermarket transaction data to uncover valuable business insights such as customer behavior, product performance, revenue patterns, and operational metrics.

📄 Dataset Overview
The dataset supermarket_sales_modified.csv contains detailed information about individual customer transactions across different supermarket branches. Each row represents one transaction.

Key columns:

store_id: Unique identifier for each store

Invoice ID: Unique identifier for each sale

Branch and City: Location information

Customer type: Member or Normal customer

Gender: Male or Female

Product line: Category of product purchased

Unit price: Price per unit

Quantity: Number of items purchased

Tax 5% and Total: Tax and total amount paid

Payment: Payment method (Cash, Credit card, Ewallet)

cogs: Cost of goods sold

Gross income: Profit from the transaction

Rating: Customer satisfaction score (1–10)

📈 Analytical Objectives

We performed several analyses to help the supermarket better understand its business operations and customer behavior:

1. **Weekly Sales Trends**  
   Tracked weekly sales from December 2018 to March 2019 to identify seasonality patterns, peak periods, and overall revenue trends.

2. **Customer Spending Behavior by Weekday**  
   Analyzed average sales per transaction by day of the week to uncover differences between weekday and weekend shopping behaviors.

3. **City-Level Sales Insights**  
   Compared weekly sales and transaction counts across different cities to identify top-performing locations and regional sales dynamics.

4. **Spending Range Analysis (Transaction Count)**  
   Categorized transactions into spending ranges to understand the frequency of different spending behaviors across cities.

5. **Spending Range Analysis (Total Sales)**  
   Analyzed total revenue contribution from each spending range, highlighting the importance of high-value transactions.

6. **Product Line Performance (Total Sales)**  
   Evaluated total sales by product line to identify the top-performing categories.

7. **Product Line Performance (Total Quantity Sold)**  
   Measured total units sold by product line to understand product demand beyond just sales value.

8. **Customer Type Contribution (Members vs. Normal)**  
   Assessed total sales generated by members compared to normal customers, demonstrating the financial impact of loyalty programs.

9. **Week-over-Week Sales Growth**  
   Calculated week-over-week sales growth to identify periods of significant increases and analyze potential causes such as promotions.

10. **Relation between Ratings and Spending**  
    Explored whether higher transaction amounts are associated with higher customer satisfaction ratings.

11. **Spending Patterns Across Weekdays by Customer Type**  
    Investigated how spending patterns vary between member and normal customers across different days of the week.

12. **Product Line Ratings Trends**  
    Tracked average ratings for each product line over time to monitor customer satisfaction and identify areas for improvement.

These analyses provided the supermarket with actionable insights into customer behavior, sales drivers, and growth opportunities, supporting data-driven decision-making for future strategies.


🛠 Tools and Libraries
Python: pandas, matplotlib, seaborn, scikit-learn

SQL: Data extraction and aggregation queries

Tableau: Analysis and visualization

