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

5. Automate ETL execution with windows task scheular
  - To run the ETL pipeline automatically every 6 hours:

  1) Create a batch file and write the code available in (`run_etl.bat`)
  2) Open Task Scheduler (Win + S → "Task Scheduler")
  3) Create Task (not Basic Task):
      - General: Give it a name (e.g. "ETL Walmart Every 6h")
      → Select "Run whether user is logged on or not"
      → Check "Run with highest privileges"
  4) Triggers → New:
      - Daily
      - Repeat task every: 6 hours
      - for a duration of: Indefinitely
  5) Actions → New:
      - Action: Start a program
      - Program/script: full path to run_etl.bat
  6) OK → enter your Windows password if prompted
  7) Test: Right-click the task → Run
      - Check output file and log to confirm it works.