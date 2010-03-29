# encoding: utf-8

# validate_equality
# validates_in [true, false, nil]
# it can work as validate_length (0..10) as well
module Formidable
  module Validations
    class ValidateEquality < Validation
      register(:validate_equality)

      def initialize(element, *values)
        @values = values
        super(element)
      end

      def valid?
        @values.include?(element.cleaned_data)
      end

      def message
        "can't be empty"
      end
    end
  end
end
