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
      participant_info   = ARGV[0] == nil ? ENV['PEOPLE_INFO'] : ARGV[0]
      self.people_info   = YAML.load(File.read(participant_info))
      self.people        = people_info.keys
      self.secret_santas = {}
      self.used          = []
      self.people        = people.shuffle
    end

    ##
    # Prints text to stdout if running with debug
    # Params:
    # +text+ - string - the message to be displayed

    def say (text)
      puts text if debug
    end

    ##
    # Gets all of the possible matches from the pool of people excluding the person themself
    # and any other people that have been matched already
    # Returns the array of possible matches
    # Params:
    # +person+ - string - the first name of the person being matched

    def possible_matches(person)
      say "Getting possible matches for #{person}"
      people.reject do |m|
        m == person || m == people_info[person]['partner'] || used.include?(m)
      end
    end

    ##
    # Logs secret santa matches to individual log files
    # Due to this being double blind these files are the main way to debug if something went wrong
    # Params:
    # +secret_santa+ - string - name of the person who is the secret santa
    # +person+ - string - the match for the secret santa which is written to the file

    def log(secret_santa, person)
      say "Logging #{secret_santa}'s match..."
      file_name = "#{secret_santa}.log"
      file = File.new "log/#{file_name}", 'w'
      file.puts file, "#{secret_santa} is #{person}'s secret santa"
      file.close
    end

    ##
    # Sends the messages for each match

    def send_messages
      secret_santas.each do |k,v|
        log(k, v)
        puts "Sending mail to #{k}"
        ElfMailer::PostalService.send_message({
          :message => ElfMailer::PostalService.form_message(k, v, ENV['budget'], ENV['message']),
          :subject => "Your Elf Mailer Secret Santa Assignment",
          :to_address => people_info[k]['email'],
          :from_address => ENV['from_email'],
          :from_name => ENV['from_name']
        })
      end
    end

    ##
    # Verifies that all of the matches are valid based on none of the pairs having an empty match
    # Returns a boolean

    def complete?
      invalid = secret_santas.select{ |k,v| v == nil }
      self.complete = invalid.empty?
      say "Here are the invalid matches: #{invalid}"
      say "Complete = #{self.complete}"
      self.complete
    end

    ##
    # Matches people all of the people in the people array
    # Assigns the matches to the secret_santas hash

    def match_people
      say "Matching people:\r#{people}"
      people.each do |p|
        say "Shuffling possible matches for #{p}"
        possible_matches = possible_matches(p).shuffle
        say "Matching #{p}"
        secret_santas[p] = possible_matches[SecureRandom.random_number(possible_matches.length - 1)]
        say "#{p} is #{secret_santas[p]}'s Secret Santa"
        used << secret_santas[p]
      end
    end

    ##
    # Runs the match for all of the people
    # Verifies that the matches are correct
    # Sends the email messages
    # Returns a the complete boolean

    def run
      match_people

      if complete?
        say secret_santas
        send_messages
      end
      complete
    end

    ##
    # Runs the run method until complete returns true

    def self.run_until_matched
      complete = false
      while complete != true
        puts "Starting new Elf Mailer run..." if ENV['DEBUG']
        complete = ElfMailer::Match.new.run
      end
      puts "Matching complete!
    end
  end
end
