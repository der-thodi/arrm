# id,permalink,thread_id,date,ip,from,to,subject,body

class ReportMessage

  attr_reader :id, :recipient

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
      @reported_account.strip!
    end

    @reported_account
  end
  
  
  def violation?
    if @violation == nil
      @violation = 'no'
      if (@body.include?('violated'))
        ret = 'yes'
      elsif (@body.include?('violates'))
        ret = 'yes'
      elsif (@body.include?('t violate '))
        ret = 'no'
      end
      @violation.strip!      
    end

    @violation
  end
  
  
  def subreddit
    ret = 'unknown'
  
    # Link to reported content: https://www.reddit.com/r/wichsbros_DE69x/comments/159etsc
    if (match = /Link to reported content:.*\/r\/([^\/]+)\//.match(@body))
      ret = match[1]
    end
  
    ret.strip!

    return ret
  end
  
  
  def violation_type
    ret = 'unknown'
  
    #Report reason: Non-consensual intimate media 
    if (match = /Report reason: (.+)/.match(@body))
      ret = match[1]
    end
  
    ret.strip!

    return ret
  end
  
  
  def user_action
    ret = 'unknown'
  
    if (match = /User ([^ ]+) was (.+)/.match(@body))
      ret = match[2]
    end
  
    ret.strip!

    return ret
  end
  

  def content_action
    ret = 'unknown'
  
    if (match = /reported content was (.+)/.match(@body))
      ret = match[1]
    end
  
    ret.strip!

    return ret
  end


  def initialize(message_fields)
    @id = message_fields['id']
    @body = message_fields['body']
    @recipient = message_fields['to']
  end


  def to_s
    "User #{reported_account()} was #{user_action()} because of #{violation_type()} in r/#{subreddit()}"
  end

end