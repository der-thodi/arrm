# Analyze Reddit Report Messages

## How to get up and running

1. Clone this repository (https://github.com/der-thodi/arrm.git)
1. `cd arrm`
1. `bundle install`
1. `bin/rails db:migrate`

## Import data

`bin/rails runner bin/import_report_messages.rb -i <directory>`