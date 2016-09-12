require 'securerandom'

module SecretSanta
  class Random
    def random_person(people)
      person = people[SecureRandom.random_number(people.length)]
    end
  end
end
