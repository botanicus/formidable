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
  class Errors < Hash
    alias_method :on,  :[]
    alias_method :add, :[]=
  end

  module Validations
    def errors
      @errors ||= Errors.new
    end

    def validations
      @validations = Array.new
    end

    def valid?
      @errors || self.validate
    end
  end
end
