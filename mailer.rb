require 'rubygems'
require 'right_aws'
require 'yaml'
require 'json'
require 'net/smtp'

class Mailer

  def initialize
    @accounts = YAML.load_file('accounts.yml')
    connect_to_sqs
    loop do
      if retrieve_msg
        parse_msg
        lookup_user
        send_email
        repost_msg_to_queue if processing_failed?
      else
        sleep 5
      end
    end
  end

  def connect_to_sqs
    aws = @accounts['sqs']
    @sqs = RightAws::SqsGen2.new(aws[:access_key_id], aws[:secret_access_key])
    @queue = @sqs.queue(aws[:queue_name])
  end

  def retrieve_msg
    @msg = @queue.pop
  end

  def parse_msg
    data = JSON.parse(@msg.body)
    @email = {
      :identifier => data["identifier"],
      :from => data["from"],
      :to => data["to"],
      :formatted => <<END_OF_MESSAGE
        From: #{data["from"]}\nTo: #{data["to"]}\nSubject: #{data["subject"]}\n
        #{data["body"]}
END_OF_MESSAGE
    }
  end

  def lookup_user
    @settings = @accounts[@email[:identifier]]
  end

  def send_email
    @response = nil
    smtp = Net::SMTP.new @settings[:server], @settings[:port]
    smtp.enable_starttls # Requires Ruby >= 1.8.7
    smtp.start Socket.gethostname, @settings[:user], @settings[:password], @settings[:authtype] do |server|
      @response = server.send_message @email[:formatted], @email[:from], @email[:to]
    end
  end

  def repost_msg_to_queue
    @queue.push(@msg.body)
  end

  def processing_failed?
    @response.status != '250' # SMTP reply code 250: Requested mail action okay, completed
  end

end

mailer = Mailer.new
