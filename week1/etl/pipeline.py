import pandas as pd
import numpy as np
import logging
import json
import os

# Setup Logger
def setup_logger():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[logging.FileHandler("logs/pipeline.log"), logging.StreamHandler()]
    )
    return logging.getLogger(__name__)

# Load Configuration
def load_config(config_path='week1/etl/config.json'):
    with open(config_path, 'r') as f:
        return json.load(f)

# Main ETL Class
class CSVETLPipeline:
    def __init__(self, config):
        self.config = config
        self.logger = setup_logger()
        self.df = None

    def extract(self):
        """Extract: Read the CSV file"""
        try:
            file_path = self.config['input_path']
            self.df = pd.read_csv(file_path)
            self.logger.info(f"Successfully loaded data from {file_path}")
        except Exception as e:
            self.logger.error(f"Error during extraction: {e}")

    def transform(self):
        """Transform: Clean and manipulate data"""
        if self.df is not None:
            # Type casting
            numeric_col = self.config.get('numeric_columns', [])
            #self.df[numeric_col] = pd.to_numeric(self.df[numeric_col], errors='coerce')
            for col in numeric_col:
                 if col in self.df.columns:
                     self.df[col] = pd.to_numeric(self.df[col], errors='coerce')


        # Remove duplicates and nulls
        self.df.drop_duplicates(inplace=True)
        self.df.dropna(inplace=True)

            # Standardize date format to '%d-%m-%Y'
            #self.df['Date'] = pd.to_datetime(self.df['Date'], errors='coerce').dt.strftime('%d-%m-%Y')
        if 'Date' in self.df.columns:
             s = self.df['Date'].astype(str).str.strip()
             parsed = pd.Series(pd.NaT, index=self.df.index)
        
             has_dash  = s.str.contains('-')
             has_slash = s.str.contains('/')
        
            # dd-mm-yyyy
             parsed[has_dash] = pd.to_datetime(s[has_dash], format='%d-%m-%Y', errors='coerce')        
            #  dd/mm/yyyy
             has_slash = (~has_dash) & s.str.contains('/')
             parsed[has_slash] = pd.to_datetime(s[has_slash], format='%d/%m/%Y', errors='coerce')
             self.df['Date'] = parsed.dt.strftime('%d/%m/%Y')

             n_failed = parsed.isna().sum()
             self.logger.info(f"Failed to transform Date |  {n_failed} of  {len(self.df)}")
        
                   
          
        # Round Fuel_Price to two decimal places
        self.df['Fuel_Price'] = self.df['Fuel_Price'].round(2)

        # Create new column (Walmart_Sales_Test) 
        self.df['Walmart_Sales_Test'] = (
            self.df['Fuel_Price'] * (self.df['CPI'] / 100)
               ).round(2)

        self.logger.info("Data transformation completed successfully.")

    def load(self):
        """Load: Save to output CSV"""
        try:
            output_path = self.config['output_path']
            self.df.to_csv(output_path, index=False)
            self.logger.info(f"Processed data saved to {output_path}")
        except Exception as e:
            self.logger.error(f"Error during loading: {e}")

# Main Entry Point
if __name__ == "__main__":
    # Ensure directories exist
    os.makedirs('logs', exist_ok=True)
    os.makedirs('processed', exist_ok=True)

    # Run Pipeline
    config = load_config()
    pipeline = CSVETLPipeline(config)
    pipeline.extract()
    pipeline.transform()
    pipeline.load()