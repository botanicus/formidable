# encoding: utf-8

module Formidable
  module Validations
    class ValidateLength < Validation
      # element.validate_length(10)
      # element.validate_length(10..20)
      # element.validate_length([10, 20])
      register(:validate_length)

      attr_reader :length
      def initialize(element, length)
        super(element)
        @length = length
      end

      def valid?
        length === element.length
      end

      def message # TODO: user can set message
        if length.respond_to?(:first)
          message_for_range
        else
          message_for_integer
        end
      end

      protected
      def message_for_integer
        "has to be #{length} characters long"
      end

      def message_for_range
        "has to be between #{length.first} and #{length.last} characters long"
      end
    end
  end
end
