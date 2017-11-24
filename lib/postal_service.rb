require 'rest-client'

module ElfMailer
  class PostalService
    def self.send_message(email_info)
      RestClient::Request.execute(
        :url => ENV['MAILER_URL']
        :method => :post,
        :payload => {
          :from => ENV['FROM'],
          :to => email_info[:to_address],
          :subject => email_info[:subject],
          :text => email_info[:message]
        },
      :verify_ssl => true
      )
    end


    def self.form_message(secret_santa, person)
      """Hello #{secret_santa},
      I'm your friendly family Secret Santa Bot writing to tell you that I have your Secret Santa Match.
      You are #{person}'s Secret Santa.

      Sincerely,

      The Mailer Elf


      If something seems wrong with this message or if you believe that you received this message in error, please let #{ENV['CONTACT_NAME']} know.
      He can be reached at #{ENV['CONTACT']}"""
    end
  end
end
