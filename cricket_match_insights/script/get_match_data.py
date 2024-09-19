import os
import mysql.connector
import requests
import csv

# Constants
API_KEY = "d1d01ec4-9cb5-4d3e-a762-fe29c7123da4"
BASE_API_URL = "https://api.cricapi.com/v1/series_info?apikey="
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(SCRIPT_DIR, '..', 'data')
CSV_FILE = os.path.join(DATA_DIR, 'cricket_match_data.csv')

# Database configuration
DB_CONFIG = {
    'user': 'root',
    'password': 'password',
    'host': 'localhost',
    'database': 'da_cricket_data',
    'raise_on_warnings': True
}

def connect_to_database():
    """Establishes a connection to the MySQL database and returns the connection object."""
    return mysql.connector.connect(**DB_CONFIG)

def get_series_ids(cursor):
    """Fetches all series IDs from the series_1 table."""
    cursor.execute("SELECT id FROM series_1")
    return [row[0] for row in cursor.fetchall()]

def fetch_series_info(series_id):
    """Fetches series information from the CricAPI for the given series_id."""
    url = f"{BASE_API_URL}{API_KEY}&id={series_id}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to fetch data for series_id {series_id}")
        return None

def extract_match_data(series_id, series_info):
    """Extracts relevant match data from the API response."""
    matches = []
    if series_info and 'data' in series_info and 'matchList' in series_info['data']:
        for match in series_info['data']['matchList']:
            match_id = match.get('id')
            match_name = match.get('name')
            match_type = match.get('matchType')
            status = match.get('status')
            venue = match.get('venue')
            date = match.get('date')
            date_time_gmt = match.get('dateTimeGMT')
            teams = match.get('teams', [])
            team1 = teams[0] if len(teams) > 0 else None
            team2 = teams[1] if len(teams) > 1 else None
            matches.append({
                'series_id': series_id,
                'match_id': match_id,
                'match_name': match_name,
                'match_type': match_type,
                'status': status,
                'venue': venue,
                'date': date,
                'date_time_gmt': date_time_gmt,
                'team1': team1,
                'team2': team2
            })
    return matches

def write_to_csv(matches, csv_file):
    """Writes the extracted match data to a CSV file."""
    with open(csv_file, mode='a', newline='') as file:
        writer = csv.writer(file)
        for match in matches:
            writer.writerow([
                match['series_id'],
                match['match_id'],
                match['match_name'],
                match['match_type'],
                match['status'],
                match['venue'],
                match['date'],
                match['date_time_gmt'],
                match['team1'],
                match['team2']
            ])

def main():
    """Main function to orchestrate the fetching and saving of match data."""
    conn = connect_to_database()
    cursor = conn.cursor()
    try:
        series_ids = get_series_ids(cursor)
        for series_id in series_ids:
            series_info = fetch_series_info(series_id)
            matches = extract_match_data(series_id, series_info)
            write_to_csv(matches, CSV_FILE)
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    # Ensure data directory exists
    os.makedirs(DATA_DIR, exist_ok=True)

    # Ensure CSV headers are written before appending data
    with open(CSV_FILE, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ['series_id', 'match_id', 'match_name', 'match_type', 'status', 'venue', 'date', 'date_time_gmt', 'team1',
             'team2'])

    main()
