require 'sqlite3'
require 'digest'
require './reportmessage'

class ReportMessageDatabase

  @@table_dml = 'create table reportmessages (
    id text not null primary key,
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
  @@table_dml_hash = Digest::SHA256.hexdigest(@@table_dml)

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
    puts " Current version:     #{@@table_dml_hash}"
    if version_in_database == nil or version_in_database != @@table_dml_hash
      puts " Updating table definition"
      statement = @db.prepare 'delete from version'
      statement.execute
      statement.close

      statement = @db.prepare 'insert into version (version) values (?)'
      statement.bind_params @@table_dml_hash
      statement.execute
      statement.close

      rows = @db.execute <<-SQLDROP
        drop table if exists reportmessages;
      SQLDROP
      rows = @db.execute @@table_dml
    else
      puts " No need to update"
    end
  end


  def save(report_message)
    puts "Saving #{report_message.id} / #{report_message.reported_account}"

    statement = @db.prepare 'insert or ignore
                             into reportmessages (id, reported_account)
                             values (?, ?)'
    statement.bind_params report_message.id,
                          report_message.reported_account

    rows = statement.execute

    #rows = @db.execute <<-SQLINSERT
    #  insert or ignore into reportmessages (id, reported_account)
    #  values (\'#{reportmessage.id}\', \'#{reportmessage.reported_account}\');
    #  
    #  -- update
    #SQLINSERT

  end


  def list_all
    statement = @db.prepare 'select * from reportmessages order by reported_account asc'
    rows = statement.execute

    while (row = rows.next) do
      puts row.join "\s"
    end
  end

  private :create_tables
end