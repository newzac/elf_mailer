#!/usr/bin/env ruby
require 'rest-client'
require 'yaml'
require 'securerandom'
require_relative './postal_service'

module ElfMailer
  class Match
    def initialize
      @people_info = YAML.load(File.read(ARGV[0]))
      @people = @people_info.keys
      @people
      @people = @people.shuffle
      #puts @people
      @secret_santas = {}
      @used = []
      #@debug = true
      @debug = false
      @complete = false
    end

    def say (text)
      puts text if @debug
    end

    def possible_matches(person)
      @people.reject do |m|
        m == person || m == @people_info[person]['partner'] || @used.include?(m)
      end
    end

    def log(secret_santa, person)
      file_name = "#{secret_santa}.log"
      file = File.new "log/#{file_name}", 'w'
      file.puts file, "#{secret_santa} is #{person}'s secret santa"
      file.close
    end


    def run
      @people.each do |p|
        possible_matches = possible_matches(p).shuffle
        @secret_santas[p] = possible_matches[SecureRandom.random_number(possible_matches.length - 1)]
        @used << @secret_santas[p]
      end

      @secret_santas.each do |k,v|
        if  v == nil
          @complete = false
          break
        else
          @complete = true
        end
      end

      say @secret_santas if @complete
      if @complete
        @secret_santas.each do |k,v|
          log(k, v)
          puts "Sending mail to #{k}"
          ElfMailer::PostalService.send_message({
            :message => ElfMailer::PostalService.form_message(k, v),
            :subject => "Mailer Elf Secret Santa Assignment",
            :to_address => @people_info[k]['email'],
            :from_address => ENV['from_email'],
            :from_name => ENV['from_name']
          })
        end
      end
      @complete
    end
  end
end

complete = false
while ! complete
  complete = ElfMailer::Match.new.run
end
