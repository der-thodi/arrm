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
    is_violation integer,
    violation_type text,
    is_first_report integer,
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
    #puts "Saving #{report_message.id} / #{report_message.reported_account}"

    statement = @db.prepare 'insert or ignore
                             into reportmessages (id, reported_account, recipient)
                             values (?, ?, ?)'
    statement.bind_params report_message.id,
                          report_message.reported_account,
                          report_message.recipient

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

  private :create_tables
end