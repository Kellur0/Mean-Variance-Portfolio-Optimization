# Mean-Variance-Portfolio-Optimization
Languages Used: PostgreSQL, R
Packages: ggplot2, zoo, PortfolioAnalytics
Tools Used: PostgreSQL, R-Studio, Microsoft Excel

Project Summary:
This project focused on optimizing a portfolio of stocks listed on the NASDAQ, NYSE, and AMEX exchanges. An Extract, Transform, Load (ETL) pipeline was developed to prepare the stock data for analysis, with a focus on mean-variance portfolio optimization based on the Markowitz Model.

Key Steps:

Extract: Combined stock data from NASDAQ, NYSE, and AMEX, along with index data (SP500TR) from Yahoo! Finance, covering the period from 2016 to 2021.
Transform:
Used R for data transformation, pivoting the dataframe with the dcast function and merging it with the trading-day calendar.
Eliminated stocks with faulty returns exceeding 100%.
Converted returns for the selected 12 assets and the benchmark index to extensible time series (XTS) format, essential for portfolio and performance analytics.
Load: Fed the XTS-transformed data into the PerformanceAnalytics package in R to compute portfolio returns.
Portfolio Optimization:
Conducted a mean-variance portfolio optimization based on the Markowitz Model, aiming to maximize returns for a given level of risk.

Skills Demonstrated:

Statistical Programming
Data Extraction and Transformation
Portfolio Optimization
R Programming and Data Visualization
ETL Process Implementation
This project showcases the practical application of statistical programming and ETL processes in financial data analysis, resulting in optimized investment portfolios.
