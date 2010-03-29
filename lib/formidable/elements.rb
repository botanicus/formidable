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

      attr_accessor :name, :raw_data, :content
      attr_reader :attributes

      def initialize(name, attributes = Hash.new, raw_data = nil)
        @name, @attributes, @raw_data = name, attributes, raw_data
        @attributes.merge!(name: name, value: raw_data)
      end
      
      def set_raw_data(raw_data)
        @raw_data = self.attributes[:value] = raw_data
      end
    end

    class ElementList < Element # pro form, group, fieldset
      # We had a few beers and we decided that this is pretty cool :)
      # This will define DSL method for creating email_field
      # @example Formidable::ElementList.register self, :email_field
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

      include GroupValidations
      def initialize(*args, &block)
        super(*args) # we need to get elements first
        self.instance_eval(&block) if block
      end

      def elements
        @elements ||= Array.new
      end

      def cleaned_data
        self.elements.inject(Hash.new) do |result, element|
          result[element.name] = element.cleaned_data
          result
        end
      end

      def raw_data
        self.elements.inject(Hash.new) do |result, element|
          result[element.name] = element.raw_data
          result
        end
      end

      protected
      def set_raw_data(raw_data)
        self.elements.each do |element|
          element.set_raw_data(raw_data[element.name]) if raw_data
        end
      end
    end

    class Form < ElementList
      renderer Renderers::Form

      # TODO: prefix should be in the form definition (name or namespace)
      def initialize(prefix = nil, attributes = Hash.new, raw_data = nil)
        self.setup
        super(prefix, attributes, raw_data)
        set_raw_data(raw_data)
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
      ElementList.register(self, :text_field)

      def initialize(name, attributes = Hash.new, raw_data = nil)
        super(name, attributes.merge!(type: "text"), raw_data)
      end

      renderer Renderers::LabeledInputRenderer
    end

    class TextArea < Element
      ElementList.register(self, :text_area)

      renderer Renderers::LabeledInputRenderer
    end

    class HiddenField < Element
      ElementList.register(self, :hidden_field)

      renderer Renderers::LabeledInputRenderer
    end

    class Submit < Element
      ElementList.register(self, :submit)

      renderer Renderers::SimpleInputRenderer

      def initialize(value = "Submit", attributes = Hash.new, raw_data = Hash.new)
        super(:submit, attributes.merge(value: value, type: "submit"), raw_data)
      end
    end

    class Button < Element
      ElementList.register(self, :button)

      renderer Renderers::Button
    end

    class Group < ElementList
      ElementList.register(self, :group)

      renderer Renderers::Group
    end

    class Fieldset < ElementList
      ElementList.register(self, :fieldset)

      renderer Renderers::Fieldset
    end

    class Legend < Element
      Fieldset.register(self, :legend)

      renderer Renderers::SimpleTagRenderer

      def initialize(content, attributes = Hash.new)
        self.content = content
        super(:legend, attributes)
      end
    end
    
    class FileField < Element
      ElementList.register(self, :file_field)

      renderer Renderers::LabeledInputRenderer

      def initialize(*args)
        super(*args)
        self.form.multipart = true
      end
    end

    class EmailField < TextField
      ElementList.register(self, :email_field)
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
