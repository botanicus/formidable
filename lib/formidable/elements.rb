# encoding: utf-8

require "formidable/validations"
require "formidable/renderers/string"

module Formidable
  class Form
    # We had a few beers and we decided that this is pretty cool :)
    # This will define DSL method for creating email_field
    # @example Formidable::Form.register self, :email_field
    def self.register(klass, method_name)
      metaclass = (class << self; self; end)
      metaclass.send(:define_method, method_name) do |name, *args, &block|
        element = klass.new(name, *args, &block)
        elements << element
        warn "Overriding method #{name}" if method_defined?(name)
        define_method(name) do
          element
        end
      end
    end
  end

  module Elements
    class Element
      include Validations
      attr_accessor :name, :value
      def initialize(name, *args, &block)
        @name = name
      end
      
      def validate
        raise NotImplementedError
      end

      def renderer
        @renderer ||= Renderers::String.new
      end

      def renderer_callable
        @renderer_callable ||= renderer[self.class]
      end

      def render
        renderer_callable.call(self, renderer)
      end
    end

    class TextField < Element
      Form.register(self, :text_field)

      Renderers::String.register(self) do |element|
        "<input name='#{element.name}' value='#{element.value}' />"
      end
    end

    class TextArea < Element
      Form.register(self, :text_area)

      Renderers::String.register(self) do |element|
      end
    end

    class HiddenField < Element
      Form.register(self, :hidden_field)

      Renderers::String.register(self) do |element|
      end
    end

    class Submit < Element
      Form.register(self, :submit)

      Renderers::String.register(self) do |element|
        self_close_tag(type: "submit", value: element.value)
        "<input type='submit' value='#{element.value}' />"
      end
    end

    class Button < Element
      Form.register(self, :button)

      Renderers::String.register(self) do |element|
      end
    end

    class Group < Element
      Form.register(self, :group)

      Renderers::String.register(self) do |element|
      end
    end

    class Fieldset < Element
      Form.register(self, :fieldset)

      Renderers::String.register(self) do |element|
      end
    end
    
    class FileField < Element
      Form.register(self, :file_field)

      def initialize(*args)
        super(*args)
        self.form.multipart = true
      end

      Renderers::String.register(self) do |element|
      end
    end

    class EmailField < TextField
      Form.register(self, :email_field)

      Renderers::String.register(self) do |e|
        element = Renderers::String.renderers[TextField].call(e)
        element["class"] = "email"
        element
      end
    end
  end
end
