# arrm
Analyze Reddit Report Mails

Generates some statistics from Reddit report messages.

## How to run
Download a copy of your Reddit data from https://www.reddit.com/settings/data-request. Unzip the zip file, there will be a file called ``messages.csv``. You can also unzip several files, from different accounts or different exports. ALl files will be loaded into the database and analyzed. You pass the script the base directory under which you unzip all zip files.

``./parse_messages.rb --input-directory <path where CSV files will be searched>``



## Tested with
 - Ruby 2.3.7
 - sqlite3 1.3.11

## Authors
 - github@thodi.de