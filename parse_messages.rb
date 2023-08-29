#!/usr/bin/env ruby

require 'csv'
require './reportmessage'
require './reportmessagedatabase'

#Submitted on: 07/24/2023 at 09:05 PM UTC      

db = ReportMessageDatabase.new()

ARGV.each do|arg|
  puts "Reading CSV: #{arg}"
  messages = CSV.read(arg, headers: true)

  messages.each do |m|
    if (ReportMessage.report_message?(m))
      db.save(ReportMessage.new(m))
    else
      #puts " Ignoring message #{i}"
    end
  end
end

db.list_all
