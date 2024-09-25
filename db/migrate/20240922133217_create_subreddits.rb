class CreateSubreddits < ActiveRecord::Migration[7.2]
  def change
    create_table :subreddits, id: :string, primary_key: :name do |t|
      t.string :status

      t.timestamps
    end
  end
end
