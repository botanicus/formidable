# encoding: utf-8

# TODO: support for errors (validate before render)
module Formidable
  module Renderers
    class Renderer
      attr_reader :element
      def initialize(element)
        @element = element
      end

      def tag(name, attributes = nil, &block)
        "<#{name}#{hash_to_attributes_string(attributes) if attributes}>#{block.call if block}</#{name}>"
      end

      def self_close_tag(name, attributes = nil)
        "<#{name}#{hash_to_attributes_string(attributes) if attributes} />"
      end

      def render
        raise NotImplementedError, "You are supposed to redefine #render method in subclasses of Renderer"
      end

      protected
      def hash_to_attributes_string(hash)
        hash.inject("") do |buffer, pair|
          attribute, value = pair
          if value == true
            buffer += " #{attribute}"
          elsif value
            buffer += " #{attribute}='#{value}'" # TODO: h(value)
          end
          buffer
        end
      end
    end

    class SimpleInputRenderer < Renderer
      def render
        self_close_tag(:input, element.attributes) + "\n"
      end
    end

    class SimpleTagRenderer < Renderer
      def render
        tag(element.tag, element.attributes) { element.content }
      end
    end

    class LongTagRenderer < SimpleTagRenderer
      def render
        super + "\n"
      end
    end

    class LabeledInputRenderer < SimpleInputRenderer
      def render
        id = element.attributes[:id] || (element.attributes[:id] = "random-#{element.object_id}")
        buffer = tag(:label, for: id) { element.attributes[:title] || element.attributes[:placeholder] } + "\n"
        buffer + super
      end
    end

    class Fieldset < SimpleInputRenderer
      def render
        tag(:fieldset) do
          element.elements.map do |element|
            element.render
          end.join("\n")
        end
      end
    end

    class Blank < Renderer
      def render
        ""
      end
    end

    class Group < Renderer
      def render
        element.elements.map do |element|
          element.render
        end.join("\n")
      end
    end

    class Form < Renderer
      # = form.render
      # = form.render do
      #   %div= form.submit
      def render(&block)
        if method = element.attributes[:method]
          set_method(method)
        end

        block ||= begin
          Proc.new do
            element.elements.map do |element|
              element.render
            end.join("\n")
          end
        end

        tag(:form, element.attributes, &block)
      end

      protected
      def set_method(method)
        if method
          if ["GET", "POST"].include?(method)
            element.attributes[:method] = method
          elsif ["PUT", "DELETE"].include?(method)
            element.attributes[:method] = "POST"
            hidden_field(:_method, value: method)
          else
            raise ArgumentError, "Method can be GET, POST, PUT or DELETE, but not #{method}"
          end
        end
      end
    end
  end
end
