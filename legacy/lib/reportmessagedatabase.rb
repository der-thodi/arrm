require 'sqlite3'
require 'digest'
require './lib/reportmessage'
require './lib/reportformattermd'
require './lib/reportformatterhtml'
require './lib/reportformattertxt'

class ReportMessageDatabase

  TABLE_DML = 'create table reportmessages (
    id text not null primary key,
    recipient text,
    report_timestamp integer,
    message_timestamp integer,
    has_two_timestamps integer,
    timestamp_difference integer,
    subreddit text,
    subreddit_is_account_profile text,
    subreddit_status text,
    violation text,
    violation_type text,
    first_report text,
    reported_account text,
    user_action text,
    content_action text,
    autogenerated_username text,
    reported_content_type text
  );'

  VIEW_DML = 'drop view if exists permanent_bans;
              create view if not exists permanent_bans as
    select reported_account as account,
           report_timestamp as timestamp
      from reportmessages r1
     where user_action like \'%permanent%\'
       and not exists (
         select reported_account
           from reportmessages r2
          where r2.reported_account = r1.reported_account
       )
  ;'

  DML_HASH = Digest::SHA256.hexdigest(TABLE_DML + VIEW_DML)

  def initialize()
    @db = SQLite3::Database.new 'reportmessages.sqlite3'

    create_tables()
  end


  def create_tables()
    puts "Creating tables as needed"

    # Create table for schema version first
    rows = @db.execute <<-SQLCREATEVERSIONTABLE
      create table if not exists version (
        version text primary key
      );
    SQLCREATEVERSIONTABLE

    # Fetch current version from database
    statement = @db.prepare 'select version from version'
    rows = statement.execute
    row = rows.next
    if row == nil
      version_in_database = 0
    else
      version_in_database = row[0]
    end
    statement.close

    puts " Version in database: #{version_in_database}"
    puts " Current version:     #{DML_HASH}"
    if version_in_database == nil or version_in_database != DML_HASH
      puts " Updating table definition"
      statement = @db.prepare 'delete from version'
      statement.execute
      statement.close

      statement = @db.prepare 'insert into version (version) values (?)'
      statement.bind_params DML_HASH
      statement.execute
      statement.close

      rows = @db.execute <<-SQLDROP
        drop table if exists reportmessages;
        drop view if exists permanent_bans;
      SQLDROP
      rows = @db.execute TABLE_DML
      rows = @db.execute VIEW_DML
    else
      puts " No need to update"
    end
  end

  def is_new?(report_message)
    statement = @db.prepare 'select count(id)
                               from reportmessages
                              where id = ?'
    statement.bind_params report_message.id
    row = statement.execute
    result = row.next[0]

    #print "Message id: #{report_message.id}, row.next[0]: #{result}\n"

    result < 1
  end

  def save(report_message)
    ret = true

    if is_new?(report_message)
      #print "insert id "
      statement = @db.prepare 'insert into reportmessages
                               (reported_account,
                                recipient,
                                subreddit,
                                violation,
                                violation_type,
                                user_action,
                                content_action,
                                message_timestamp,
                                report_timestamp,
                                has_two_timestamps,
                                timestamp_difference,
                                first_report,
                                autogenerated_username,
                                reported_content_type,
                                subreddit_is_account_profile,
                                id)
                                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    else
      ret = false
      #print "update id "
      statement = @db.prepare 'update reportmessages
                                  set reported_account = ?,
                                      recipient = ?,
                                      subreddit = ?,
                                      violation = ?,
                                      violation_type = ?,
                                      user_action = ?,
                                      content_action = ?,
                                      message_timestamp = ?,
                                      report_timestamp = ?,
                                      has_two_timestamps = ?,
                                      timestamp_difference = ?,
                                      first_report = ?,
                                      autogenerated_username = ?,
                                      reported_content_type = ?,
                                      subreddit_is_account_profile = ?
                                where id = ?'
    end
    #print "#{report_message.id}\n"
    statement.bind_params report_message.reported_account,
                          report_message.recipient,
                          report_message.subreddit,
                          report_message.violation?,
                          report_message.violation_type,
                          report_message.user_action,
                          report_message.content_action,
                          report_message.message_timestamp,
                          report_message.report_timestamp,
                          (report_message.report_timestamp == nil) ? 0 : 1,
                          report_message.message_timestamp.to_i - report_message.report_timestamp.to_i,
                          report_message.first_report?,
                          report_message.autogenerated_username?,
                          report_message.reported_content_type,
                          report_message.subreddit_is_account_profile?,
                          report_message.id
    rows = statement.execute
    statement.close

    ret
  end


  def list_all
    statement = @db.prepare 'select * from reportmessages order by reported_account asc'
    rows = statement.execute

    while (row = rows.next) do
      puts row.join "\s"
    end
    statement.close
  end


  def print_subreddit_stats(rows_in_subreddit_breakdown = -1)
    statement = @db.prepare 'select count(*) from (
                               select distinct subreddit
                                 from reportmessages
                             )' 

    row = statement.execute
    puts "Subreddits: #{row.next[0]}"
    statement.close

    if rows_in_subreddit_breakdown != 0
      statement = @db.prepare 'select subreddit, count(*)
                                from reportmessages
                                group by subreddit
                                order by 2 desc
                                limit ?'
      statement.bind_params rows_in_subreddit_breakdown
      rows = statement.execute
      if (rows_in_subreddit_breakdown > 0)
        puts "Subreddit breakdown: (Top #{rows_in_subreddit_breakdown})"
      else
        puts "Subreddit breakdown:"
      end
      while (row = rows.next)
        puts " '#{row[0]}': #{row[1]}"
      end
      statement.close
    end
  end


  def print_ban_stats
    statement = @db.prepare 'select count(*) from (
                               select distinct reported_account
                                 from reportmessages
                                where user_action like \'%permanent%\'
                             )' 

    row = statement.execute
    puts "Permanent bans: #{row.next[0]}"
    statement.close

    statement = @db.prepare 'select count(*) from (
                               select distinct reported_account
                                 from reportmessages
                                where user_action like \'%tempo%\'
                             )' 

    row = statement.execute
    puts "Temporary bans: #{row.next[0]}"
    statement.close
  end


  def print_violation_type_stats
    statement = @db.prepare 'select violation_type, count(*)
                               from reportmessages
                              group by violation_type
                              order by 2 desc'
    rows = statement.execute
    puts "Violation breakdown:"
    while (row = rows.next)
      puts " '#{row[0]}': #{row[1]}"
    end
    statement.close
  end


  def print_removal_stats
    statement = @db.prepare 'select count(*)
                               from reportmessages
                              where content_action like \'%removed%\''
    rows = statement.execute
    puts "Items removed: #{rows.next[0]}"
    statement.close
  end


  def print_reported_content_type_stats
    statement = @db.prepare 'select count(*)
                               from reportmessages
                              where reported_content_type = \'post\''
    rows = statement.execute
    posts = rows.next[0]
    puts "Posts: #{posts}"
    statement.close

    statement = @db.prepare 'select count(*)
                               from reportmessages
                              where reported_content_type = \'comment\''
    rows = statement.execute
    comments = rows.next[0]
    puts "Comments: #{comments}"
    statement.close

    puts "Total: #{comments + posts}"
  end

  def print_time_stats
    statement = @db.prepare 'select min(message_timestamp), id
                               from reportmessages'
    rows = statement.execute
    row = rows.next
    puts "Oldest message: #{ReportMessage.timestamp_as_date(row[0])} (#{row[1]})"
    statement.close

    statement = @db.prepare 'select max(message_timestamp), id
                               from reportmessages'
    rows = statement.execute
    row = rows.next
    puts "Newest message: #{ReportMessage.timestamp_as_date(row[0])} (#{row[1]})"
    statement.close

    statement = @db.prepare 'select max(timestamp_difference), id
                               from reportmessages
                              where has_two_timestamps = 1'
    rows = statement.execute
    row = rows.next
    puts "Longest reaction time:  #{ReportMessage.format_processing_time(row[0])} (#{row[1]})"
    statement.close

    statement = @db.prepare 'select min(timestamp_difference), id
                               from reportmessages
                              where has_two_timestamps = 1'
    rows = statement.execute
    row = rows.next
    puts "Shortest reaction time: #{ReportMessage.format_processing_time(row[0])} (#{row[1]})"
    statement.close

    statement = @db.prepare 'select avg(timestamp_difference)
                               from reportmessages
                              where has_two_timestamps = 1'
    rows = statement.execute
    row = rows.next
    puts "Average reaction time:  #{ReportMessage.format_processing_time(row[0])}"
    statement.close
  end


  def print_violation_stats
    statement = @db.prepare 'select count(*)
                               from reportmessages
                              where violation = \'yes\''
    rows = statement.execute
    violations = rows.next[0]
    puts "Confirmed violations: #{violations}"
    statement.close

    statement = @db.prepare 'select count(*)
                               from reportmessages
                              where violation = \'no\''
    rows = statement.execute
    no_violations = rows.next[0]
    puts "No violation: #{no_violations}"
    statement.close

    puts "Successful: #{violations / ((violations + no_violations) / 100)}%"
  end

  
  def print_username_stats
    statement = @db.prepare 'select count(*)
                               from reportmessages
                              where autogenerated_username = \'yes\''
    rows = statement.execute
    autogenerated_usernames = rows.next[0]
    puts "Autogenerated names: #{autogenerated_usernames}"
    statement.close

    statement = @db.prepare 'select distinct reported_account
                               from reportmessages
                              where autogenerated_username = \'no\'
                              order by reported_account asc'
    rows = statement.execute
    print "Chosen usernames: "
    while (row = rows.next)
      print "'#{row[0]}', "
    end
    puts
    statement.close
  end


  def print_subreddit_css
    
  end

  def print_reporter_stats
    puts "Reporter stats:"
    statement = @db.prepare 'select recipient, count(*)
                               from reportmessages
                              group by recipient
                              order by count(*) desc'
    rows = statement.execute
    while (row = rows.next)
      name = row[0]
      count = row[1]
      puts " #{name}: #{count}"
    end
    statement.close
  end

  def print_subreddit_details
    subreddits = Array.new

    statement = @db.prepare 'select distinct subreddit
                               from reportmessages'
    rows = statement.execute
    while (row = rows.next)
      subreddits << row[0]
    end
    statement.close

    subreddits.each { |sub|
      statement = @db.prepare 'select distinct reported_account
                                 from reportmessages
                                where subreddit = ?
                                  and violation = \'yes\''
      statement.bind_params sub
      rows = statement.execute
      puts "Sub: #{sub}"
      while (row = rows.next)
        print "#{row[0]} "
      end
      puts
      statement.close
    }

  end


  def run_file_report(options)
    output_file = options[:output_file]

    output_format = File.extname(output_file).downcase
    output_format.slice! "."
    puts "Writing report in '#{output_format}' format to '#{output_file}'"

    reportformatter = nil

    if (output_format == 'txt')
      reportformatter = ReportFormatterTXT.new(options)
    elsif (output_format == 'md')      
      reportformatter = ReportFormatterMD.new(options)
    elsif (output_format == 'html')
      reportformatter = ReportFormatterHTML.new(options)
    else
      puts "Unknown format '#{output_format}'"
      return
    end

    reportformatter.print_global_header

    reportformatter.print_summary_header

    #
    # Get global stats
    #
    stats = {}

    #
    # Posts
    #
    posts_statement = @db.prepare 'select count(*)
                                     from reportmessages
                                    where reported_content_type = \'post\''
    posts = posts_statement.execute
    stats[:reported_posts] = posts.next[0]
    posts_statement.close

    #
    # Comments
    #
    comments_statement = @db.prepare 'select count(*)
                                        from reportmessages
                                       where reported_content_type = \'comment\''
    comments = comments_statement.execute
    stats[:reported_comments] = comments.next[0]
    comments_statement.close

    #
    # First reports
    #
    first_reports_statement = @db.prepare 'select count(*)
                                             from reportmessages
                                             where first_report = \'yes\''
    first_reports = first_reports_statement.execute
    stats[:first_reports] = first_reports.next[0]
    first_reports_statement.close

    #
    # Violations
    #
    violations_statement = @db.prepare 'select count(*)
                                          from reportmessages
                                         where violation = \'yes\''
    violations = violations_statement.execute
    stats[:violations] = violations.next[0]
    violations_statement.close

    #
    # No Violations
    #
    no_violations_statement = @db.prepare 'select count(*)
                                             from reportmessages
                                            where violation = \'no\''
    no_violations = no_violations_statement.execute
    stats[:no_violations] = no_violations.next[0]
    no_violations_statement.close

    #
    # Permanent bans
    #
    permanent_bans_statement = @db.prepare 'select count(distinct reported_account)
                                              from reportmessages
                                              where user_action like \'%permanent%\''
    permanent_bans = permanent_bans_statement.execute
    stats[:permanent_bans] = permanent_bans.next[0]
    permanent_bans_statement.close

    #
    # Termporary bans
    #
    temporary_bans_statement = @db.prepare 'select count(distinct reported_account)
                                              from reportmessages
                                              where user_action like \'%tempo%\''
    temporary_bans = temporary_bans_statement.execute
    stats[:temporary_bans] = temporary_bans.next[0]
    temporary_bans_statement.close

    #
    # Warnings
    #
    warnings_statement = @db.prepare 'select count(distinct reported_account)
                                        from reportmessages
                                        where user_action like \'%warning%\''
    warnings = warnings_statement.execute
    stats[:warnings] = warnings.next[0]
    warnings_statement.close

    reportformatter.print_summary_stats(stats)
    reportformatter.print_summary_footer

    reportformatter.print_violation_breakdown_header
    reportformatter.print_violation_breakdown
    reportformatter.print_violation_breakdown_footer  

    reportformatter.print_subreddit_header
    #
    # Loop through all distinct subs
    #
    statement = @db.prepare 'select distinct subreddit
                               from reportmessages
                              order by 1 asc'
    rows = statement.execute
    while (row = rows.next)
      stats = {}
      stats[:name] = row[0]

      #
      # Get stats for this sub
      #

      #
      # Posts
      #
      posts_statement = @db.prepare 'select count(*)
                                       from reportmessages
                                      where reported_content_type = \'post\'
                                        and subreddit = ?'
      posts_statement.bind_params stats[:name]
      posts = posts_statement.execute
      stats[:reported_posts] = posts.next[0]
      posts_statement.close

      #
      # Comments
      #
      comments_statement = @db.prepare 'select count(*)
                                          from reportmessages
                                         where reported_content_type = \'comment\'
                                           and subreddit = ?'
      comments_statement.bind_params stats[:name]
      comments = comments_statement.execute
      stats[:reported_comments] = comments.next[0]
      comments_statement.close

      #
      # First reports
      #
      first_reports_statement = @db.prepare 'select count(*)
                                              from reportmessages
                                              where first_report = \'yes\'
                                              and subreddit = ?'
      first_reports_statement.bind_params stats[:name]
      first_reports = first_reports_statement.execute
      stats[:first_reports] = first_reports.next[0]
      first_reports_statement.close

      #
      # Violation / No violation
      #
      violations_statement = @db.prepare 'select count(*)
                                            from reportmessages
                                           where subreddit = ?
                                             and violation = \'yes\''
      violations_statement.bind_params stats[:name]
      violations = violations_statement.execute
      stats[:violations] = violations.next[0]
      violations_statement.close

      no_violations_statement = @db.prepare 'select count(*)
                                               from reportmessages
                                              where subreddit = ?
                                                and violation = \'no\''
      no_violations_statement.bind_params stats[:name]
      no_violations = no_violations_statement.execute
      stats[:no_violations] = no_violations.next[0]
      no_violations_statement.close

      #
      # Permanent bans
      #
      permanent_bans_statement = @db.prepare 'select distinct reported_account
                                                from reportmessages
                                               where user_action like \'%permanent%\'
                                                 and subreddit = ?
                                               order by reported_account asc'
      permanent_bans_statement.bind_params stats[:name]
      permanent_bans = permanent_bans_statement.execute
      stats[:permanent_bans] = []
      while (permananent_ban = permanent_bans.next) do
        stats[:permanent_bans] << "u/#{permananent_ban[0]}"
      end
      permanent_bans_statement.close

      #
      # Termporary bans
      #
      temporary_bans_statement = @db.prepare 'select distinct reported_account
                                                from reportmessages
                                               where user_action like \'%tempo%\'
                                                 and subreddit = ?
                                               order by reported_account asc'
      temporary_bans_statement.bind_params stats[:name]
      temporary_bans = temporary_bans_statement.execute
      stats[:temporary_bans] = []
      while (temporary_ban = temporary_bans.next) do
        stats[:temporary_bans] << "u/#{temporary_ban[0]}"
      end
      temporary_bans_statement.close

      #
      # Warnings
      #
      warnings_statement = @db.prepare 'select distinct reported_account
                                          from reportmessages
                                         where user_action like \'%warning%\'
                                           and subreddit = ?
                                         order by reported_account asc'
      warnings_statement.bind_params stats[:name]
      warnings = warnings_statement.execute
      stats[:warnings] = []
      while (warning = warnings.next) do
        stats[:warnings] << "u/#{warning[0]}"
      end
      warnings_statement.close

      reportformatter.print_stats_for_sub(stats)
    end
    statement.close

    reportformatter.print_subreddit_footer

    reportformatter.print_global_footer
  end

  def get_subreddits
    subreddits = []

    statement = @db.prepare 'select distinct subreddit
                               from reportmessages
                              where subreddit_is_account_profile = \'no\''
    statement_result = statement.execute
    while (subreddit = statement_result.next) do
      #puts "Adding #{subreddit}"
      subreddits << subreddit[0]
    end
    statement.close

    subreddits
  end

  def get_subreddit_status(subreddit)
    statement = @db.prepare 'select distinct subreddit_status
                               from reportmessages
                              where subreddit = ?'
    statement.bind_params subreddit
    statement_result = statement.execute

    i = 0
    s = ''
    while (status = statement_result.next) do
      s = status[0]
      i = i + 1
    end
    statement.close

    if i == 1
      s
    else
      '?'
    end
  end

  def set_subreddit_status(subreddit, status)
    statement = @db.prepare 'update reportmessages
                                set subreddit_status = ?
                              where subreddit = ?'
    statement.bind_params status, subreddit
    statement.execute
    statement.close
  end

 # def update_missing_status_for_subreddits
 #   statement = @db.prepare 'update reportmessages out_
 #                               set subreddit_status = 
 #
 #                                  (select max(subreddit_status)
 #                                      from reportmessages in_
 #                                     where out_.subreddit = in_subreddit)
 #                             where subreddit_status is null
 #                               and exists (select SYNTAX ERROR)'
 # end

  private :create_tables
end