require 'rest-client'

module ElfMailer
  class PostalService
    def self.send_message(email_info)
      RestClient::Request.execute(
        :url => ENV['mailer_url'],
        :method => :post,
        :payload => {
          :from => "#{email_info[:from_name]} #{email_info[:from_address]}",
          :to => email_info[:to_address],
          :subject => email_info[:subject],
          :text => email_info[:message]
        },
      :verify_ssl => true
      )
    end


    def self.form_message(secret_santa, person)
      """Hello #{secret_santa},
      I'm your friendly Secret Santa Bot writing to tell you that I have your Secret Santa Match.
      You are #{person}'s Secret Santa. This year please keep the gift buying to a budget of $25.

      Sincerely,

      #{ENV['from_name']}


      If something seems wrong with this message or if you believe that you received this message in error, please let #{ENV['contact_name']} know.
      He can be reached at #{ENV['contact_email']}"""
    end
  end
end
