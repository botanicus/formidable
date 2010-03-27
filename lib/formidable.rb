# encoding: utf-8

require "formidable/rendering"
require "formidable/elements"
require "formidable/validations"
require "formidable/renderers/string"

# TODO: form should be an element
# TODO: errors should respond to :add, :on
# TODO: linked list rather than arrays
# plnenei dat
module Formidable
  class Form < ElementList
    renderer Renderers::Form

    def initialize(data, attributes = Hash.new)
      @data, @attributes = data, attributes
      set_method(options[:method]) if options[:method]
    end

    def validate
      self.elements.inject(self.errors) do |errors, element|
        unless element.valid?
          errors[element.name] = element.errors
        end
      end
    end

    def save(*args)
      raise NotImplementedError, "You have to redefine this method in subclasses!"
    end
    alias_method :save!, :save

    def update(*args)
      raise NotImplementedError, "You have to redefine this method in subclasses!"
    end
    alias_method :update!, :update
  end
end
