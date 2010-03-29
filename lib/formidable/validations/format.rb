# encoding: utf-8

# validate_format /\d+/
module Formidable
  module Validations
    class ValidateFormat < Validation
      register(:validate_format)

      def initialize(element, format)
        @format = format
        super(element)
      end

      def valid?
        element.cleaned_data.match(@format)
      end

      def message
        "can't be empty"
      end
    end
  end
end
