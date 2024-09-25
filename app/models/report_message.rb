class ReportMessage < ApplicationRecord
  self.primary_key = :message_id
  belongs_to :subreddit
end
