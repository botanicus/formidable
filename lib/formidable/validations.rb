# encoding: utf-8

=begin rdoc
  Co musi validace delat:
    - mixin s instancnima metodama:
      - errors
      - validations
      - valid?
      - validate
    - mixin s makrama (taky instancni metody)
    - vlastni validacni klasy
=end

module Formidable
  module Validations
    def errors
      @errors ||= Hash.new
    end

    def validations
      @validations = Array.new
    end

    def valid?
      @errors || self.validate
    end
  end
end
