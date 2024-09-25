class Subreddit < ApplicationRecord
  self.primary_key = :name
  has_many :report_messages
end
