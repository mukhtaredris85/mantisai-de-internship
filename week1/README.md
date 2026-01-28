# Walmart Sales ETL Pipeline

A simple ETL process for handling Walmart store weekly sales data.

The program performs the following tasks:
- Reading the CSV file
- Cleaning the data (removing duplicates, handling missing values)
- Standardizing the date format to `dd-mm-yyyy`
- Rounding the fuel price to two decimal places
- Creating a derived column `Walmart_Sales_Test` = `Fuel_Price × (CPI / 100)`
- Saving the result to a new CSV file

## Requirements

- Python 3.9 or higher
- Required libraries (see `requirements.txt`)

## Project Structure


etl-project/
├── pipeline.py               # Main ETL script
├── config.json               # Configuration file (paths, transformations, etc.)
├── requirements.txt
├── data/
│   ├── raw/
│   │   └── walmart_sales.csv     # Original input file
│   └── processed/
│       └── walmart_sales_cleaned.csv   # Output file
└── logs/
    └── pipeline.log          # Execution logs

## How to Run
1. Prepare the files
  - Make sure you have pipeline.py, config.json, and requirements.txt in your project folder
  - Place the input file walmart_sales.csv inside data/raw/

2. Install dependencies
  - pip install -r requirements.txt

3. Run the ETL pipeline

4. Expected output
  - Processed file: data/processed/walmart_sales_cleaned.csv (you can change the path in config.json)
  - Log file: logs/pipeline.log