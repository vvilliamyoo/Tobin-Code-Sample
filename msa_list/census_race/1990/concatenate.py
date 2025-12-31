import pandas as pd
import os

# Read the Excel file
script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
file_path = os.path.join(script_dir, 'edited_race_1990.xlsx')
xls = pd.ExcelFile(file_path)

# Load the first sheet into a DataFrame
first_sheet = xls.parse(0)  # Assuming the first sheet index is 0

# Loop through the remaining sheets (starting from the second sheet)
for sheet_index in range(1, len(xls.sheet_names)):
    sheet_name = xls.sheet_names[sheet_index]
    df = xls.parse(sheet_index)
    first_sheet = pd.concat([first_sheet, df], ignore_index=True)

# Write the combined data to a new Excel file
output_csv_path = os.path.join(script_dir, 'final_race_1990.csv')
first_sheet.to_csv(output_csv_path, index=False)
