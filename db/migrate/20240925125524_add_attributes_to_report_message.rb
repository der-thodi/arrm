class AddAttributesToReportMessage < ActiveRecord::Migration[7.2]
  def change
    add_column :report_messages, :sender, :string
    add_column :report_messages, :permalink, :string
    add_column :report_messages, :body, :text
  end
end
