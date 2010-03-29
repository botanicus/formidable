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

  module Elements
    class Element
      def self.register_validation(klass, method_name) # TODO: pridavat to spis do validations mixinu nez primo do elementu
        define_method(method_name) do |*args, &block|
          validation = klass.new(self, *args, &block)
          validations << validation
          self
        end
      end
    end
  end

  module Validations
    def errors
      @errors ||= Array.new
    end

    def validations
      @validations ||= Array.new
    end

    def valid?
      @errors || self.validate
    end

    def validate
      self.validations.inject(true) do |is_valid, validation|
        validation_passed = validation.valid?
        unless validation_passed
          self.errors.push(validation.message)
        end
        is_valid && validation_passed
      end
    end
  end

  module GroupValidations # TODO: better name
    include Validations
    def errors
      @errors ||= Errors.new
    end

    def before_validate
    end

    def validate
      self.before_validate
      self.elements.each do |element|
        unless element.valid?
          errors[element.name] = element.errors
        end
      end
      self.errors.empty?
    end
  end

  class Validations::Validation
    def self.register(method_name)
      Elements::Element.register_validation(self, method_name)
    end

    attr_reader :element
    def initialize(element)
      @element = element
    end

    def valid?
      raise NotImplementedError, "You have to redefine #valid? in subclasses of the Validation class"
    end

    def message
      raise NotImplementedError, "You have to redefine #message in subclasses of the Validation class"
    end
  end
end
