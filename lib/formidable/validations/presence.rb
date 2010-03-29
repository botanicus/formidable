# encoding: utf-8

module Formidable
  module Validations
    class ValidatePresence < Validation
      register(:validate_presence)

      def valid?
        ! element.cleaned_data.nil?
      end

      def message
        "can't be empty"
      end
    end
  end
end
