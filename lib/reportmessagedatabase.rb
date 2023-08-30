require 'sqlite3'
require 'digest'
require './lib/reportmessage'

class ReportMessageDatabase

  TABLE_DML = 'create table reportmessages (
    id text not null primary key,
    recipient text,
    report_timestamp integer,
    message_timestamp integer,
    subreddit text,
    violation integer,
    violation_type text,
    first_report integer,
    reported_account text,
    user_action text,
    content_action text
  );'
  TABLE_DML_HASH = Digest::SHA256.hexdigest(TABLE_DML)

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
    version_in_database = rows.next[0]
    statement.close

    puts " Version in database: #{version_in_database}"
    puts " Current version:     #{TABLE_DML_HASH}"
    if version_in_database == nil or version_in_database != TABLE_DML_HASH
      puts " Updating table definition"
      statement = @db.prepare 'delete from version'
      statement.execute
      statement.close

      statement = @db.prepare 'insert into version (version) values (?)'
      statement.bind_params TABLE_DML_HASH
      statement.execute
      statement.close

      rows = @db.execute <<-SQLDROP
        drop table if exists reportmessages;
      SQLDROP
      rows = @db.execute TABLE_DML
    else
      puts " No need to update"
    end
  end


  def save(report_message)
    # make sure the entry exists
    statement = @db.prepare 'insert or ignore
                               into reportmessages (id)
                             values (?)'
    statement.bind_params report_message.id
    rows = statement.execute

    # now fill in the values
    statement = @db.prepare 'update reportmessages
                             set reported_account = ?,
                                 recipient = ?,
                                 subreddit = ?,
                                 violation = ?,
                                 violation_type = ?,
                                 user_action = ?,
                                 content_action = ?,
                                 message_timestamp = ?,
                                 report_timestamp =?
                             where id = ?'
    statement.bind_params report_message.reported_account,
                          report_message.recipient,
                          report_message.subreddit,
                          report_message.violation?,
                          report_message.violation_type,
                          report_message.user_action,
                          report_message.content_action,
                          report_message.message_timestamp,
                          report_message.report_timestamp,
                          report_message.id
    rows = statement.execute
    statement.close
  end


  def list_all
    statement = @db.prepare 'select * from reportmessages order by reported_account asc'
    rows = statement.execute

    while (row = rows.next) do
      puts row.join "\s"
    end
    statement.close
  end


  def print_subreddit_stats
    statement = @db.prepare 'select count(*) from (
                               select distinct subreddit
                                 from reportmessages
                             )' 

    row = statement.execute
    puts "Subreddits: #{row.next[0]}"
    statement.close

    statement = @db.prepare 'select subreddit, count(*)
                               from reportmessages
                              group by subreddit
                              order by 2 desc'
    rows = statement.execute
    puts "Subreddit breakdown:"
    while (row = rows.next)
      puts " '#{row[0]}': #{row[1]}"
    end
    statement.close
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
  end
  
  private :create_tables
end