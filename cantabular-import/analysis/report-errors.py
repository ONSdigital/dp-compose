import sys
from pathlib import Path

filename = "count-log-events/instance-events.txt"

line_number = 0
error_found = 0
download_error_count = 0
kafka_timeout_count = 0
kafka_sending_error_count = 0
put_version_count = 0

my_file = Path(filename)
if my_file.is_file():
    # file exists

    with open(filename) as file:
        for line in file:
            line_number += 1
            if "error" in line:
                if "dp-download-service" in line:
                    # As at 16th December 2021 this is not fully used in the test stack, so not all of its dependencies
                    # have been set up and to avoid false positive error reporting we ignore any of its errors.
                    download_error_count += 1
                    continue
                if "Request exceeded the user-specified time limit in the request" in line:
                    kafka_timeout_count += 1
                    continue
                if "consumer-group error sending error to the error channel" in line:
                    kafka_sending_error_count += 1
                if "putVersion endpoint: failed to update version document" in line:
                    put_version_count += 1
                    continue
                if error_found == 0:
                    error_found = 1
                    print("\nFound error(s) in: ", filename, "\n")
                print("line: ", line_number, "\n  ", line.lstrip())

if download_error_count > 0:
    print("    Had a download-service error count of: ", download_error_count, " -> ignore these !")

if kafka_timeout_count > 0:
    print("    Had a kafka timeout error count of: ", kafka_timeout_count, " -> ignore these ! (but this needs fixing in sarama lib)")

if kafka_sending_error_count > 0:
    print("    Had a 'consumer-group error sending error to the error channel': ", kafka_sending_error_count, " -> ignore these ! (but this needs fixing in sarama lib)")

if put_version_count > 0:
    print("    Had a put version error count of: ", put_version_count)

if error_found == 0:
    print("    No unexpected error(s) found\n")

# now look for `DATA RACE` in 'all-container-logs.txt'

filename = "tmp/all-container-logs.txt"

line_number = 0
race_error_found = 0

my_file = Path(filename)
if my_file.is_file():
    # file exists

    with open(filename, encoding="utf8") as file:
        for line in file:
            line_number += 1
            if "DATA RACE" in line:
                if race_error_found == 0:
                    race_error_found = 1
                    print("\nFound DATA RACE in: ", filename, "\n")
                print("line: ", line_number, "\n  ", line.lstrip())

if race_error_found == 0:
    print("    No DATA RACE's found\n")

if race_error_found > 0 or error_found > 0 or put_version_count > 0:
    sys.exit(1)
