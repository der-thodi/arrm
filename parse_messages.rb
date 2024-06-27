#!/usr/bin/env ruby

require 'csv'
require 'find'
require 'getoptlong'
require './lib/reportmessage'
require './lib/reportmessagedatabase'

#Submitted on: 07/24/2023 at 09:05 PM UTC      

PRIVACY_FOR_REPORTERS = 1
PRIVACY_FOR_REPORTED  = 2

opts = GetoptLong.new(
  [ '--input-directory', '-i', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--privacy', '-p', GetoptLong::REQUIRED_ARGUMENT],
  [ '--run-reports', '-r', GetoptLong::NO_ARGUMENT],
  [ '--output-file', '-o', GetoptLong::REQUIRED_ARGUMENT],
  [ '--count-per-file', '-c', GetoptLong::NO_ARGUMENT]
)

begin
  options = {}
  #
  # privacy:
  #   0: none
  #   1: privacy for reporter accounts
  #   2: privacy for reported accounts
  #
  options[:privacy] = 0

  options[:run_reports] = false

  options[:output_file] = ""

  options[:count_per_file] = false

  opts.each do |opt, arg|
    case opt
    when '--input-directory'
      options[:input_directory] = arg
    when '--privacy'
      options[:privacy] = arg.to_i
    when '--run-reports'
      options[:run_reports] = true
    when '--output-file'
      options[:output_file] = arg
    when '--count-per-file'
      options[:count_per_file] = true
    else
      puts "Unknown option #{opt}"
      exit 1
    end
  end

rescue GetoptLong::Error => e
  puts e.message
  exit 1
end

puts options

db = ReportMessageDatabase.new()
i = 1
if (options.key?(:input_directory) and options[:input_directory] != '') 
  Find.find(options[:input_directory]) do |path|
    if (FileTest.file?(path) and path =~ /messages.csv/)
      if ((options[:privacy] & PRIVACY_FOR_REPORTERS) > 0)
        puts "Reading CSV"
      else
        puts "Reading CSV: #{path}"
      end
      messages = CSV.read(path, headers: true)

      if (options[:count_per_file])
        i = 1
      end
      messages.each do |m|
        if (ReportMessage.report_message?(m))
          rm = ReportMessage.new(m)
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
  end
else
  puts "No input files"
end

if (options[:run_reports])
  if (options[:output_file] != "")
    db.run_file_report(privacy: options[:privacy], output_file: options[:output_file])
  else
    # basic
    #db.list_all
    db.print_reported_content_type_stats
    db.print_violation_stats
    db.print_violation_type_stats
    db.print_ban_stats
    db.print_subreddit_stats(10)
    #db.print_removal_stats
    #db.print_username_stats
    db.print_time_stats
    #db.print_subreddit_details
    if not ((options[:privacy] & PRIVACY_FOR_REPORTERS) > 0) 
      db.print_reporter_stats
    end
  end
end