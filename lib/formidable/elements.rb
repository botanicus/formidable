# encoding: utf-8

require "formidable/coercions"
require "formidable/rendering"
require "formidable/validations"
require "formidable/renderers/string"

module Formidable
  module Elements
    class Element
      include Rendering
      include Validations
      include Coercions

      attr_accessor :name, :data
      attr_reader :attributes

      def initialize(name, attributes = Hash.new, data = nil)
        @name, @attributes, @data = name, attributes, data
        @attributes.merge!(name: name)
      end
      
      def validate
        self.validations.inject(true) do |is_valid, validation|
          is_valid && validation.validate
        end
      end

      alias_method :inspect, :render
    end

    class ElementList < Element # pro form, group, fieldset
      def initialize(*args, &block)
        super(*args, &block)
        set_data
      end

      def elements
        @elements ||= Array.new
      end

      def validate
        self.elements.inject(self.errors) do |errors, element|
          unless element.valid?
            errors[element.name] = element.errors
          end
        end
      end

      protected
      def set_data
        @data ||= data
        self.elements.each do |element|
          element.data = @data[element.name]
        end
      end
    end

    class Form < ElementList
      renderer Renderers::Form

      # We had a few beers and we decided that this is pretty cool :)
      # This will define DSL method for creating email_field
      # @example Formidable::Form.register self, :email_field
      def self.register(klass, method_name)
        define_method(method_name) do |name, *args, &block|
          element = klass.new(name, *args, &block)
          elements << element
          warn "Overriding method #{name}" if self.class.method_defined?(name)
          self.class.send(:define_method, name) do
            element
          end
          element
        end
      end

      def initialize(prefix = Array.new, attributes = Hash.new, data = nil)
        super(prefix, attributes, data)
        self.setup
      end

      def setup
        raise NotImplementedError, "You are supposed to redefine the setup method in subclasses of Element!"
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

      def initialize(value = "Submit", attributes = Hash.new, data = Hash.new)
        super(Array.new, attributes.merge(value: value), data)
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
