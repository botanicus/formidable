# encoding: utf-8

require "formidable/rendering"
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
        element
      end
    end
  end

  module Elements
    class Element
      include Rendering
      include Validations
      attr_accessor :name, :value
      def initialize(name, attributes = nil, &block)
        @name, @attributes = name, attributes
      end

      def attributes
        @attributes ||= {name: name, value: value}
      end
      
      def validate
        self.validations.inject(true) do |is_valid, validation|
          is_valid && validation.validate
        end
      end
    end

    class ElementList < Element # pro form, group, fieldset
      def self.elements
        @elements ||= Array.new
      end

      def elements
        self.class.elements
      end
    end

    class TextField < Element
      Form.register(self, :text_field)

      renderer Renderers::LabeledInputRenderer
    end

    class TextArea < Element
      Form.register(self, :text_area)

      renderer Renderers::LabeledInputRenderer
    end

    class HiddenField < Element
      Form.register(self, :hidden_field)

      renderer Renderers::LabeledInputRenderer
    end

    class Submit < Element
      Form.register(self, :submit)

      renderer Renderers::SimpleInputRenderer

      def initialize(value = "Submit", attributes = Hash.new, &block)
        @attributes = attributes.merge(value: value)
      end
    end

    class Button < Element
      Form.register(self, :button)

      renderer Renderers::Button
    end

    class Group < ElementList
      Form.register(self, :group)

      renderer Renderers::Blank
    end

    class Fieldset < ElementList
      Form.register(self, :fieldset)

      renderer Renderers::Fieldset
    end
    
    class FileField < Element
      Form.register(self, :file_field)

      renderer Renderers::LabeledInputRenderer

      def initialize(*args)
        super(*args)
        self.form.multipart = true
      end
    end

    class EmailField < TextField
      Form.register(self, :email_field)
    end

    # zna to svoje name => vi kde v params to najit
    # {date: "27-07-2010"} => {date: #<Date:x0>}
    class DateSelectField < Element
      # TOHLE BUDE V SUPERCLASS
      # jak to ma dostat params?
      def deserialize
        # [:post, :title]
        self.name.inject(params) do |hash, key|
          hash[key]
        end
      end

      # TOHLE BUDE TADY
      def deserialize
        Date.new(super)
      end
    end
  end
end
