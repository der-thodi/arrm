# arrm
Analyze Reddit Report Mails

Generates some statistics from reddit report messages.

## How to run
Download a copy of your reddit data from https://www.reddit.com/settings/data-request. Unzip the zip file, there will be a file called ``messages.csv``. If you have multiple accounts, you can also pass it multiple files.

``./parse_messages.rb /path/to/messages.csv /path/to/another/messages.csv``

## Tested with
 - Ruby 2.3.7
 - sqlite3 1.3.11

## Authors
 - github@thodi.de