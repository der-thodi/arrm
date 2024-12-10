# arrm
Analyze Reddit Report Mails

Generates some statistics from Reddit report messages.

## How to run
Download a copy of your Reddit data from https://www.reddit.com/settings/data-request. Unzip the zip file, there will be a file called ``messages.csv``. You can also unzip several files, from different accounts or different exports. All files will be loaded into the database and analyzed. You pass the script the base directory under which you unzip all zip files.

``./parse_messages.rb --input-directory <path where CSV files will be searched>``

When the database structure changes or you delete the database file, all messages will need to be reread - otherwise, only new messages will be added to the database.

The subreddit status (banned, private, etc.) is set with an extra program, as this actually needs an internet connection:

``./update_sub_status.rb``

## How to get a report

``./parse_messages.rb --run-reports --output-file <output file>``

The output format is automatically determined by the output file extension.
Output file formats are:
- Markdown (extenion .md)
- HTML (extension .html)
- TXT (extension .txt)

## Tested with
- MacBook Pro:
  - ruby 2.3.7p456 (2018-03-28 revision 63024) \[universal.x86_64-darwin17\]
  - sqlite3 1.3.11
  - 116 meesages/s
- Raspberry Pi:
  - ruby 2.5.5p157 (2019-03-15 revision 67260) \[arm-linux-gnueabihf\]
  - sqlite3 1.3.11
  - 8.5 messages/s
- HP Intel workstation (Intel(R) Core(TM)2 Duo CPU     E6850  @ 3.00GHz)
  - ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) \[x86_64-linux-gnu\]
  - sqlite3 3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837balt1
  - 68.3 messages/second

## Authors
- github@thodi.de