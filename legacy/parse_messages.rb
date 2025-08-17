#!/usr/bin/env ruby

require 'csv'
require 'find'
require 'getoptlong'
require './lib/reportmessage'
require './lib/reportmessagedatabase'

#Submitted on: 07/24/2023 at 09:05 PM UTC      

opts = GetoptLong.new(
  [ '--input-directory', '-i', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--run-reports', '-r', GetoptLong::NO_ARGUMENT ],
  [ '--output-file', '-o', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--privacy-for-offenders', '-p', GetoptLong::NO_ARGUMENT ],
  [ '--privacy-for-reporters', '-P', GetoptLong::NO_ARGUMENT ],
)

begin
  options = {}

  options[:run_reports] = false

  options[:output_file] = ""

  options[:privacy_for_offenders] = false

  options[:privacy_for_reporters] = false

  opts.each do |opt, arg|
    case opt
    when '--input-directory'
      options[:input_directory] = arg
    when '--run-reports'
      options[:run_reports] = true
    when '--output-file'
      options[:output_file] = arg
    when '--privacy-for-offenders'
      options[:privacy_for_offenders] = true
    when '--privacy-for-reporters'
      options[:privacy_for_reporters] = true
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
if (options.key?(:input_directory) and options[:input_directory] != '')
  total_messages = 0
  start_time = Time.new()
  Find.find(options[:input_directory]) do |path|
    if (FileTest.file?(path) and (path =~ /\/messages.csv/ or path =~ /\/announcements.csv/))
      new_reports = 0
      old_reports = 0
      other_messages = 0

      if (options[:privacy_for_reporters])
        print "Reading CSV "
      else
        print "Reading CSV: #{path} "
      end
      messages = CSV.read(path, headers: true, encoding: 'utf-8')

      messages.each do |m|
        if (ReportMessage.report_message?(m, path))
          rm = ReportMessage.new(m, path)
          ret = db.save(rm)
          if (ret)
            new_reports = new_reports + 1
          else
            old_reports = old_reports + 1
          end
        else
          other_messages = other_messages + 1
        end
      end
      puts "(#{new_reports + old_reports + other_messages} total, #{new_reports} new, #{old_reports} old, #{other_messages} other messages)"
      total_messages = total_messages + new_reports + old_reports + other_messages
    end
  end
  end_time = Time.new()
  diff = end_time.to_i - start_time.to_i
  print "#{total_messages} messages in #{diff} seconds"
  if (diff > 0)
    puts " (#{(total_messages / (diff * 1.0)).round(1)} messages/second)"
  else
    puts ""
  end
else
  puts "No input files"
end

if (options[:run_reports])
  if (options[:output_file] != "")
    db.run_file_report(options)
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
    if not (options[:privacy_for_reporters]) 
      db.print_reporter_stats
    end
  end
end