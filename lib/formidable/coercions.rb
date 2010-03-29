# encoding: utf-8

module Formidable
  module Coercions
    MissingCoercion       = Class.new(StandardError)
    IncompatibleInterface = Class.new(StandardError)

    def self.coercions
      @coercions ||= Hash.new do |hash, key|
        raise MissingCoercion, "No coercion defined for #{key}"
      end
    end

    # default coercions
    coercions[:integer] = Proc.new { |value| value.to_i }
    coercions[:float]   = Proc.new { |value| value.to_f }

    def self.included(klass)
      if ! klass.method_defined?(:raw_data) || ! klass.method_defined?(:cleaned_data=)
        raise IncompatibleInterface, "You are supposed to define #{klass}#raw_data and #{klass}#cleaned_data= in order to get coercions running!"
      end
    end

    def cleaned_data
      @cleaned_data ||= self.coerce!
    end

    def coercions
      @coercions ||= Array.new
    end

    def coerce(type = nil, &block)
      if type && block.nil?
        coercions << Coercions.coercions[type]
      elsif type.nil? && block
        coercions << block
      else
        raise ArgumentError, "provide block or type"
      end
    end

    def coerce!
      self.cleaned_data = begin
        coercions.inject(self.raw_data) do |coercion, raw_data|
          coercion.call(raw_data)
        end
      end
    end
  end
end
