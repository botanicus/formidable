# encoding: utf-8

module Formidable
  module Validations
    class ValidatePresence < Validation
      register(:validate_presence)

      def initialize(*args)
        super(*args)

        # HTML 5
        unless element.attributes.has_key?(:required)
          element.attributes[:required] = true
        end
      end

      def valid?
        ! element.cleaned_data.nil?
      end

      def message
        "can't be empty"
      end
    end
  end
end
