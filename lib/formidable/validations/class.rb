# encoding: utf-8

# validate_class Fixnum
# validate_class Numeric
module Formidable
  module Validations
    class ValidateClass < Validation
      register(:validate_class)

      def initialize(element, klass)
        @klass = klass
        super(element)
      end

      def valid?
        element.cleaned_data.is_a?(@klass)
      end

      def message
        "can't be empty"
      end
    end
  end
end
