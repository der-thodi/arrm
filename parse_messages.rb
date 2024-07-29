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
    when '--privacy'
      options[:privacy] = arg.to_i
    when '--run-reports'
      options[:run_reports] = true
    when '--output-file'
      options[:output_file] = arg
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
  Find.find(options[:input_directory]) do |path|
    if (FileTest.file?(path) and path =~ /\/messages.csv/)
      new_messages = 0
      old_messages = 0

      if (options[:privacy_for_reporters])
        print "Reading CSV "
      else
        print "Reading CSV: #{path} "
      end
      messages = CSV.read(path, headers: true, encoding:'utf-8')

      messages.each do |m|
        if (ReportMessage.report_message?(m))
          rm = ReportMessage.new(m)
          ret = db.save(rm)
          if (ret)
            new_messages = new_messages + 1
          else
            old_messages = old_messages + 1
          end
        else
          #puts " Ignoring message #{i}"
        end
      end
      puts "(#{new_messages} new, #{old_messages} old)"
    end
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