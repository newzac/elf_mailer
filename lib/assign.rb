require_relative './random'


module SecretSanta
  class Assign
    def secret_santa(person, people, couples, secret_santas)
      ss_selector = SecretSanta::Random.new
      spouse = couples[person] || couples.select{ |k, v| v == person}.keys[0]
      puts "#{person}'s spouse is #{spouse}"
      puts "#{person}'s possible secret santas are #{possibleSS}"
      ss = ss_selector.random_person(possibleSS)
      secret_santas[ss] = person
      puts "#{person}'s secret santa is #{ss}\n\n"
    end

    def possible_secret_santas(person, people, couples, secret_santas)
      people.reject{ |p| p == spouse || p == person || secret_santas[p] != nil }
    end

    def isSelf?(person, other)
      person == other
    end

    def isSpouse?(person, other, spouse)
    end
  end
end
