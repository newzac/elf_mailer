require 'net/smtp'
require_relative './random.rb'
require_relative './assign.rb'

module SecretSanta
  class Match
    def initialize
      @couples = {"Ainsley" => "Eric", "Whitley" => "Dave", "Kaari" => "Zachary"}
      @people = ["Erik"]
      @couples.each{ |k,v| @people += [k, v] }
      @secret_santas = {}
      @debug = true
    end
    
    def say (text)
      puts text if @debug
    end
    
    def run
      assign = SecretSanta::Assign.new
      @people.shuffle.each{ |person| assign.secret_santa(person, @people, @couples, @secret_santas)}
      say @secret_santas
      @secret_santas.each do |k,v|
        if k == nil or v ==nil
          SecretSanta::Match.new.run
        end
      end
    end
  end
end
SecretSanta::Match.new.run
