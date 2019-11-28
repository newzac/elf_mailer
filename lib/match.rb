#!/usr/bin/env ruby
require 'rest-client'
require 'yaml'
require 'securerandom'
require_relative './postal_service'

module ElfMailer
  class Match
    attr_accessor :complete, :debug, :people_info, :people, :secret_santas, :used
    def initialize
      self.complete      = false
      self.debug         = ENV['DEBUG'] || false
      self.people_info   = YAML.load(File.read(ARGV[0]))
      self.people        = people_info.keys
      #puts people if debug
      self.secret_santas = {}
      self.used          = []
      self.people             = people.shuffle
    end

    def say (text)
      puts text if debug
    end

    def possible_matches(person)
      say "Getting possible matches for #{person}"
      people.reject do |m|
        m == person || m == people_info[person]['partner'] || used.include?(m)
      end
    end

    def log(secret_santa, person)
      say "Logging #{secret_santa}'s match..."
      file_name = "#{secret_santa}.log"
      file = File.new "log/#{file_name}", 'w'
      file.puts file, "#{secret_santa} is #{person}'s secret santa"
      file.close
    end

    def send_messages
      secret_santas.each do |k,v|
        log(k, v)
        puts "Sending mail to #{k}"
        ElfMailer::PostalService.send_message({
          :message => ElfMailer::PostalService.form_message(k, v),
          :subject => "Mailer Elf Secret Santa Assignment",
          :to_address => people_info[k]['email'],
          :from_address => ENV['from_email'],
          :from_name => ENV['from_name']
        })
      end
    end

    def complete?
      secret_santas.each do |k,v|
        if  v == nil
          complete = false
          break
        else
          complete = true
        end
      end

      say "Complete = #{complete}"
      complete
    end

    def match_people
      say "Matching people:\r#{people}"
      people.each do |p|
        say "Shuffling possible matches for #{p}"
        possible_matches = possible_matches(p).shuffle
        say "Matching #{p}"
        secret_santas[p] = possible_matches[SecureRandom.random_number(possible_matches.length - 1)]
        used << secret_santas[p]
      end
    end

    def run
      match_people

      if complete?
        say secret_santas
        send_messages
      end

      complete
    end

    def self.run_until_matched
      complete = false
      while ! complete
        say "Starting new Elf Mailer run..."
        complete = ElfMailer::Match.new.run
      end
    end
  end
end
