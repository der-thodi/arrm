#!/usr/bin/env ruby

require 'getoptlong'
require 'net/http'
require './lib/reportmessagedatabase'

def parse_status(html)
  if html.match(/r\/.+is banned/)
    'banned'
  elsif html.match(/r\/ is private/)
    'private'
  elsif html.match(/Community not found/)
    'not found'
  else
    'open'
  end
end

def check_subreddit_status(uri, limit = 4)
  raise ArgumentError, 'too many HTTP redirects' if limit == 0

  #puts "Checking #{uri}"
  response = Net::HTTP.get_response(URI(uri))

  case response
  when Net::HTTPSuccess then
    parse_status(response.body)
  when Net::HTTPRedirection then
    location = response['location']
    if location.start_with?('/')
      location = "https://www.reddit.com#{location}"
    end
    #warn "redirected to #{location}"
    check_subreddit_status(location, limit - 1)
  else
    #parse_status(response.body)
  end

end

db = ReportMessageDatabase.new()
subreddits = db.get_subreddits

puts "#{subreddits.length} subs"

subreddits.each do |subreddit|
  status = db.get_subreddit_status(subreddit)
  #puts "#{subreddit} -> #{status}"
  if status.nil? or status.length < 1
    new_status = check_subreddit_status("https://www.reddit.com/r/#{subreddit}/")
    if new_status.nil? or new_status.length < 1
      warn "Can not get status for r/#{subreddit}"
      exit 1
    else
      puts "Updating status of r/#{subreddit} to '#{new_status}'"
      db.set_subreddit_status(subreddit, new_status)
    end
  end 
end