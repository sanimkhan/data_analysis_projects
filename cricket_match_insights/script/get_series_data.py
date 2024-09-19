import os
import requests
import csv

# API key and endpoint
API_KEY = "d1d01ec4-9cb5-4d3e-a762-fe29c7123da4"
API_URL = "https://api.cricapi.com/v1/series"
BATCH_SIZE = 25
TOTAL_ROWS = 628
CSV_COLUMNS = ["id", "name", "startDate", "endDate", "odi", "t20", "test", "squads", "matches"]

# Define the data directory relative to the script's directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(SCRIPT_DIR, '..', 'data')
CSV_FILE = os.path.join(DATA_DIR, "cricket_series_data.csv")

def fetch_series_data(offset):
    """
    Fetch data from the API with the given offset.
    """
    params = {
        "apikey": API_KEY,
        "offset": offset
    }
    response = requests.get(API_URL, params=params)
    return response.json()

def write_to_csv(data, file):
    """
    Write the fetched series data to the CSV file.
    """
    with open(file, mode='a', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=CSV_COLUMNS)
        for series in data:
            writer.writerow({
                "id": series["id"],
                "name": series["name"],
                "startDate": series["startDate"],
                "endDate": series.get("endDate", ""),
                "odi": series["odi"],
                "t20": series["t20"],
                "test": series["test"],
                "squads": series["squads"],
                "matches": series["matches"]
            })

def initialize_csv(file):
    """
    Initialize the CSV file and write the header.
    """
    with open(file, mode='w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=CSV_COLUMNS)
        writer.writeheader()

def main():
    """
    Main function to fetch data and save it to a CSV file.
    """
    # Ensure the data directory exists
    os.makedirs(DATA_DIR, exist_ok=True)

    initialize_csv(CSV_FILE)

    offset = 0
    while offset < TOTAL_ROWS:
        # Fetch data from API
        response_data = fetch_series_data(offset)

        # Check if the response was successful
        if response_data['status'] == 'success':
            # Write data to CSV
            write_to_csv(response_data['data'], CSV_FILE)
        else:
            print(f"Failed to fetch data at offset: {offset}")
            break

        # Increment offset for the next batch
        offset += BATCH_SIZE

    print(f"Data has been successfully saved to {CSV_FILE}.")

if __name__ == "__main__":
    main()
