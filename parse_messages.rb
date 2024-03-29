#!/usr/bin/env ruby

require 'csv'
require './lib/reportmessage'
require './lib/reportmessagedatabase'

#Submitted on: 07/24/2023 at 09:05 PM UTC      

db = ReportMessageDatabase.new()
i = 1
ARGV.each do|arg|
  puts "Reading CSV: #{arg}"
  messages = CSV.read(arg, headers: true)

  messages.each do |m|
    if (ReportMessage.report_message?(m))
      rm = ReportMessage.new(m)
      #puts "#{i}: #{rm.to_s}"
      db.save(rm)
      i += 1
      if i % 100 == 0
        print "...#{i}"
      end
    else
      #puts " Ignoring message #{i}"
    end
  end
  puts "...#{i}"
end

#db.list_all
db.print_reported_content_type_stats
db.print_violation_stats
db.print_violation_type_stats
db.print_ban_stats
#db.print_subreddit_stats(20)
#db.print_removal_stats
#db.print_username_stats
db.print_time_stats
#db.print_subreddit_details