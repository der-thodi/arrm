# id,permalink,thread_id,date,ip,from,to,subject,body

class ReportMessage

  attr_reader :id

  def self.report_message?(message)
    message['subject'] == 'We Have Reviewed Your Report'
  end


  def first_report?
    if @first_report == nil
      @first_report = @body.include?('already been investigated') ? 'no' : 'yes'
    end

    @first_report
  end
  
  
  def reported_account
    if @reported_account == nil
      @reported_account = 'unknown'
      #Reported account(s): Salty\-Essay721 
      #that the account(s) Plenty\_Cod2067 
      if (match = /Reported account\(s\): (.+)/.match(@body))
        @reported_account = match[1]
      elsif (match = /that the account\(s\) ([^ ]+)/.match(@body))
        @reported_account = match[1]
      end

      @reported_account.gsub!(/\\/, '')
    end

    @reported_account
  end
  
  
  def violation?
    ret = 'no'
  
    if (@body.include?("violated"))
      ret = 'yes'
    elsif (@body.include?("violates"))
      ret = 'yes'
    elsif (@body.include?("t violate "))
      ret = 'no'
    end
  
    return ret
  end
  
  
  def subreddit
    ret = 'unknown'
  
    # Link to reported content: https://www.reddit.com/r/wichsbros_DE69x/comments/159etsc
    if (match = /Link to reported content:.*\/r\/([^\/]+)\//.match(@body))
      ret = match[1]
    end
  
    return ret
  end
  
  
  def violation_type
    ret = 'unknown'
  
    #Report reason: Non-consensual intimate media 
    if (match = /Report reason: (.+)/.match(@body))
      ret = match[1]
    end
  
    return ret
  end
  
  
  def user_action
    ret = 'unknown'
  
    if (match = /User ([^ ]+) was (.+)/.match(@body))
      ret = match[2]
    end
  
    return ret
  end
  

  def content_action
    ret = 'unknown'
  
    if (match = /reported content was (.+)/.match(@body))
      ret = match[1]
    end
  
    return ret
  end

  # def parse_message_fields(message_fields)
  #   m = message_fields
  #
  #   @date = m['date']
  #   puts " Looking at message ID #{@id}"
  #  
  #   @body = m['body']
  #
  #   @is_violation = is_violation?()
  #   puts "  Is violation? #{@is_violation}"
  #
  #   @violation_type = get_violation_type()
  #   puts "  Violation type? #{@violation_type}"
  #
  #   @subreddit = get_subreddit()
  #   puts "  Subreddit? #{@subreddit}"
  #  
  #   @is_first_report = is_first_report?()
  #   puts "  First report? #{@is_first_report}"
  #
  #   @reported_account = get_reported_account()
  #   puts "  Reported account? #{@reported_account}"
  #
  #   @user_action = get_user_action()
  #   puts "  User action? #{@user_action}"
  #
  #   @content_action = get_content_action()
  #   puts "  Content action? #{@content_action}"
  # end


  def initialize(message_fields)
    @id = message_fields['id']
    @body = message_fields['body']
    #parse_message_fields(message_fields)
  end


  #private :parse_message_fields
end