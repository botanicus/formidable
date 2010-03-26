# encoding: utf-8

require "formidable/elements"
require "formidable/validations"
require "formidable/renderers/string"

module Formidable
  class Form
    include Validations
    Renderers::String.register(self) do |form|
      if (method = form.attributes[:method])
        if ["GET", "POST"].include?(method)
          form[:method] = method
        elsif ["PUT", "DELETE"].include?(method)
          form[:method] = "POST"
          hidden_field(:_method, value: method)
        else
          raise ArgumentError, "Method can be GET, POST, PUT or DELETE, but not #{method}"
        end
      end

      buffer = String.new
      buffer << "<form>"
      form.elements.each do |element|
        buffer += element.render
      end
      buffer += "</form>"
      buffer
    end

    def self.elements
      @elements ||= Array.new
    end

    def initialize(data, options = Hash.new)
      @data, @options = data, options
      set_method(options[:method]) if options[:method]
    end

    def elements
      self.class.elements
    end

    def group
      OpenStruct.new
    end

    def validate
      self.fields.inject(self.errors) do |errors, field|
        unless field.valid?
          errors[field.name] = field.errors
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

    attr_writer :renderer
    def renderer
      @renderer ||= begin
        ancestor = self.class.ancestors.find do |ancestor|
          if ancestor.is_a?(Class)
            Renderers::String.renderers.has_key?(ancestor)
          end
        end
        Renderers::String.renderers[ancestor]
      end
    end

    def render
      renderer.call(self)
    end
  end
end
