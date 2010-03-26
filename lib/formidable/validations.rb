# encoding: utf-8

begin
  require "validatable"
rescue LoadError
  raise LoadError, "You have to install the validatable gem if you want to use Formidable::Validations mixin!"
end

module Formidable
  module Validations
    def errors
      @errors ||= Validatable::Errors.new
    end

    def valid?
      self.validate
      self.errors.empty?
    end

    def validate_presence
      Validatable::ValidatesPresenceOf.new(self)
      self
    end

    def validate_length(length)
      Validatable::ValidatesLengthOf.new(self, length)
      self
    end

    def validate_acceptance(length)
      Validatable::ValidatesAcceptanceOf.new(self, length)
      self
    end

    def validate_confirmation(length)
      Validatable::ValidatesConfirmationOf.new(self, length)
      self
    end
    
    def validate_each(length)
      Validatable::ValidatesEach.new(self, length)
      self
    end
    
    def validate_format(length)
      Validatable::ValidatesFormatOf.new(self, length)
      self
    end

    def validate_numericality(length)
      Validatable::ValidatesNumericalityOf.new(self, length)
      self
    end
    
    def validate_true_for(length)
      Validatable::ValidatesTrueFor.new(self, length)
      self
    end
  end
end
