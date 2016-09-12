require 'net/smtp'
require_relative './random.rb'

module SecretSanta
  class Match
    def initialize
      @couples = {"Ainsley" => "Eric", "Whitley" => "Dave", "Kaari" => "Zachary"}
      @people = []
      @people_to_emails = []
      @couples.each{ |k,v| @people += [k, v] }
      puts @people
      @secret_santas = {}
      @try
    end

    def random_person
      @people[SecureRandom.random_number(@people.length + 1)]
    end



    def get_secret_santa (person)
      spouse = @couples[person] || @couples.select{ |k, v| v == person }.keys[0]
      people = @people.reject do |santa| santa == spouse || santa == person end
      secret_santa = SecretSanta::Random.new.random_person(people) 
      puts "#{person}'s secret santa is #{secret_santa}\n"
      @try = 1
      while (secret_santa == spouse  || @secret_santas[secret_santa] != nil.to_s || secret_santa == person) && @try < 100
        secret_santa = SecretSanta::Random.new.random_person(people)
        @try += 1
      end
      if @try >= 100
        puts "Warning: Pairs may be inconsistent"
      end
  
      @secret_santas[secret_santa.to_s] = person
      puts "#{person}'s secret santa is #{secret_santa}\n"
    end
  
    def create_message (person, secret_santa, to_address)
      message = <<-END_OF_MESSAGE
      From: Secret Santa <secret-santa@zachandkaari.com>
      To: #{secret_santa} #{to_address}
      Date: #{Time.now}
      Message-Id: <#{SecureRandom.random_hex(10)}-#{name}-secret-santa@zachandkaari.com>

      Hello #{secret_santa},\n
      I'm your friendly family Secret Santa Bot writing to tell you that I have your Secret Santa Match.\n
      You are #{person}'s secret santa.\n
      \n
      Sincerely,\n
      \n
      Secret Santa Bot\n
      \n
      \n
      If something seems wrong with this message or if you believe that you recieved this message in error, please let @znewman know.\n
      He can be reached at z@znewman.com
      END_OF_MESSAGE

    end

    def send_message (message, to_address)
      Net::SMTP.start('smtp-relay.gmail.com', 587) do |smtp|
        smtp.send_message message, 'secret-santa@zachandkaari.com', to_address
      end
    end


    def run
      @people.shuffle
      @secret_santas = {}
      message = ""
      @people.each{ |person| message << get_secret_santa(person).to_s }
      if @try > 99
        self.run
      else
        puts message
      end
    end
  end
end

SecretSanta::Match.new.run
