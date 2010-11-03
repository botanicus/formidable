# encoding: utf-8

# NOTE: this could be done via validate_equality with block as well
# confirmation = text_field(:password_confirmation)
# text_field(:password).validate_confirmation(confirmation)

# text_field(:password).validate_confirmation do
#   text_field(:password_confirmation)
# end
module Formidable
  module Validations
    class ValidateConfirmation < Validation
      register(:validate_confirmation)

      def initialize(element, confirmation_field = nil, &block)
        set_confirmation_field(confirmation_field, block)
        super(element)
      end

      def valid?
        @confirmation_field.cleaned_data == element.cleaned_data
      end

      def message
        "has to match #{@confirmation_field.name}"
      end

      protected
      def set_confirmation_field(field, callable)
        @confirmation_field = begin
          if field && callable.nil?
            field
          elsif field.nil? && callable
            callable.call
          else
            raise ArgumentError, "You are supposed to provide field or callable"
          end
        end
      end
    end
  end
end

# module Validatable
#   class ValidatesConfirmationOf < ValidationBase #:nodoc:
#     option :case_sensitive
#     default :case_sensitive => true
#
#     def valid?(instance)
#       return instance.send(self.attribute) == instance.send("#{self.attribute}_confirmation".to_sym) if case_sensitive
#       instance.send(self.attribute).to_s.casecmp(instance.send("#{self.attribute}_confirmation".to_sym).to_s) == 0
#     end
#
#     def message(instance)
#       super || "doesn't match confirmation"
#     end
#   end
# end
