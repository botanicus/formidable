# encoding: utf-8

require "formidable/rendering"
require "formidable/renderers/string"

module Formidable
  module Elements
    class BasicElement
      attr_accessor :tag, :name, :raw_data, :content
      attr_writer :cleaned_data
      attr_reader :attributes

      include Rendering

      def initialize(tag, name, attributes = Hash.new, raw_data = nil)
        @tag, @name, @attributes = tag, name, attributes
        @attributes.merge!(name: name) if name
        self.raw_data = raw_data if raw_data
      end

      def cleaned_data
        @cleaned_data || self.raw_data
      end
    end

    require "formidable/coercions"
    require "formidable/validations"

    class Element < BasicElement
      include Validations
      include Coercions
    end

    class ElementList < BasicElement # pro form, group, fieldset
      # We had a few beers and we decided that this is pretty cool :)
      # This will define DSL method for creating email_field
      # @example Formidable::ElementList.register self, :email_field
      def self.register(klass, method_name)
        define_method(method_name) do |*args, &block|
          element = klass.new(*args, &block)
          elements << element
          unless element.name.nil?
            if self.class.method_defined?(element.name)
              warn "Overriding method #{element.name}"
            end
            self.class.send(:define_method, element.name) do
              element
            end
          end
          element
        end
      end

      include GroupValidations

      # This is pretty much just a copy of Element#initialize, it's because
      # if we'd use super, then the Element#raw_data=(raw_data) would be called,
      # but we actually need to trigger the ElementList#raw_data=(raw_data).
      def initialize(tag, name, attributes = Hash.new, raw_data = nil, &block)
        @tag, @name, @attributes = tag, name, attributes
        @attributes.merge!(name: name) if name
        self.raw_data = raw_data if raw_data
        self.instance_eval(&block) if block
      end

      def elements
        @elements ||= Array.new
      end

      def content
        self.elements.inject(String.new) do |buffer, element|
          buffer += "\n" + element.render
        end
      end

      def raw_data
        self.elements.inject(Hash.new) do |result, element|
          if element.name && element.raw_data
            result[element.name] = element.raw_data
          end
          result
        end
      end

      def raw_data=(raw_data)
        return if raw_data.nil?
        raw_data.each do |key, value|
          element = self.send(key)
          element.raw_data = value
        end
      end

      def cleaned_data
        self.elements.inject(Hash.new) do |result, element|
          if element.name && element.raw_data
            result[element.name] = element.cleaned_data
          end
          result
        end
      end

      # TODO: this should be done dynamically, something like:
      # def name
      #   self.parent.name + @name
      # end
      def set_prefix(prefix)
        self.elements.each do |element|
          if element.respond_to?(:elements) && element.name
            element.set_prefix("#{prefix}[#{element.name}]")
          end
          if element.attributes[:name]
            element.attributes[:name] = begin
              "#{prefix}[#{element.attributes[:name]}]"
            end
          end
        end
      end
    end

    class Form < ElementList
      renderer Renderers::Form

      # TODO: prefix should be in the form definition (name or namespace)
      def initialize(action, method = "POST", prefix = nil, attributes = Hash.new, raw_data = Hash.new)
        @raw_data = raw_data
        self.setup
        super(:form, nil, attributes.merge!(action: action, method: method), raw_data)
        set_prefix(prefix) if prefix
        self.raw_data = raw_data
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

    class Input < Element
      def initialize(name, attributes = Hash.new, raw_data = nil)
        super(:input, name, attributes, raw_data)
      end

      def raw_data=(raw_data)
        self.attributes[:value] = super(raw_data)
      end
    end

    class TextField < Input
      ElementList.register(self, :text_field)

      def initialize(name, attributes = Hash.new, raw_data = nil)
        super(name, attributes.merge!(type: "text"), raw_data)
      end

      renderer Renderers::LabeledInputRenderer
    end

    class TextArea < Element
      ElementList.register(self, :text_area)

      renderer Renderers::SimpleTagRenderer

      def initialize(*args, &block)
        super(:textarea, *args, &block)
      end

      def raw_data=(raw_data)
        @raw_data = self.content = raw_data
      end
    end

    class HiddenField < Input
      ElementList.register(self, :hidden_field)

      renderer Renderers::SimpleInputRenderer

      def initialize(name, attributes = Hash.new, raw_data = nil)
        super(name, attributes.merge!(type: "hidden"), raw_data)
      end
    end

    class CheckBox < Input
      ElementList.register(self, :check_box)

      def initialize(name, attributes = Hash.new, raw_data = nil)
        super(name, attributes.merge!(type: "checkbox"), raw_data)
      end

      renderer Renderers::LabeledInputRenderer
    end

    class Submit < Input
      ElementList.register(self, :submit)

      renderer Renderers::SimpleInputRenderer

      def initialize(value = "Submit", attributes = Hash.new)
        super(nil, attributes.merge(value: value, type: "submit"))
      end
    end

    class Button < Element
      ElementList.register(self, :button)

      renderer Renderers::SimpleTagRenderer

      def initialize(attributes = Hash.new, &block)
        self.content = block.call
        super(:button, nil, attributes)
      end
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

    class FileField < Input
      ElementList.register(self, :file_field)

      renderer Renderers::LabeledInputRenderer

      def initialize(name, attributes = Hash.new)
        super(name, attributes.merge!(type: "file"))
        self.form.multipart = true
      end
    end

    class EmailField < Input
      ElementList.register(self, :email_field)

      renderer Renderers::LabeledInputRenderer

      def initialize(name = :email, attributes = Hash.new, raw_data = nil)
        super(name, attributes.merge!(type: "email"), raw_data)
      end
    end

    class PasswordField < Input
      ElementList.register(self, :password_field)

      renderer Renderers::LabeledInputRenderer

      def initialize(name = :password, attributes = Hash.new)
        super(name, attributes.merge!(type: "password"))
      end
    end

    class Select < ElementList
      include Validations # for validations purposes it behaves just as an element # TODO: doesn't workf
      # The reason is simple, Validations are already included in GroupValidations, so it doesn't really include the mixin here

      ElementList.register(self, :select)

      renderer Renderers::SimpleTagRenderer

      def initialize(name, attributes = Hash.new, &block)
        super(:select, name, attributes, &block)
      end

      def selected
        self.elements.find do |element|
          element.attributes[:selected]
        end
      end

      def raw_data
        self.selected.raw_data if self.selected
      end

      def raw_data=(raw_data)
        if raw_data.nil?
          self.selected.attributes.delete(:selected)
        else
          self.elements.find do |element|
            if element.raw_data == raw_data
              element.attributes[:selected] = true
            end
          end
        end
      end

      def cleaned_data
        self.selected && self.selected.cleaned_data
      end
    end

    class Option < Element
      Select.register(self, :option)

      renderer Renderers::SimpleTagRenderer

      def initialize(value, attributes = Hash.new, &block)
        self.content = block.call
        super(:option, nil, attributes.merge!(value: value))
      end

      def raw_data
        @raw_data ||= self.attributes[:value]
      end

      def cleaned_data
        @cleaned_data ||= self.raw_data
      end
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
