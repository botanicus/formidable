# encoding: utf-8

module Formidable
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
    class Validation
      def self.register(method_name)
        Elements::Element.register_validation(self, method_name)
      end

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

    class ValidatePresence < Validation
      register(:validate_presence)

      def valid?
        ! attributes[:value].nil?
      end

      def message
        "can't be empty"
      end
    end
  end
end
