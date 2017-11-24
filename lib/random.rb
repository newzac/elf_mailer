require 'securerandom'

module ElfMailer
  class Random
    def random_person(people)
      person = people[SecureRandom.random_number(people.length - 1)]
    end
  end
end
