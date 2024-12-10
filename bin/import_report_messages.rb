require 'csv'
require 'find'
require 'getoptlong'

opts = GetoptLong.new(
  [ '--input-directory', '-i', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--privacy-for-reporters', '-P', GetoptLong::NO_ARGUMENT ],
)

begin
  options = {}

  options[:privacy_for_reporters] = false

  opts.each do |opt, arg|
    case opt
    when '--input-directory'
      options[:input_directory] = arg
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

if (options.key?(:input_directory) and options[:input_directory] != '')
  total_messages = 0
  start_time = Time.new()
  Find.find(options[:input_directory]) do |path|
    if (FileTest.file?(path) and path =~ /\/messages.csv/)
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
        puts m
        rm = ReportMessage.new(m)
        if (ReportMessage.valid?)
          ret = rm.save(rm)
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