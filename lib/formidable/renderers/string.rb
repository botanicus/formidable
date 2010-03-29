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
        "<#{name}#{hash_to_attributes_string(attributes) if attributes}>#{"\n#{block.call}\n" if block}</#{name}>"
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
          if value
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
        tag(element.name, element.attributes) { element.content } + "\n"
      end
    end

    class LabeledInputRenderer < SimpleInputRenderer
      def render
        id = element.attributes[:id]
        raise "You have to provide id attribute if you want to use LabeledInputRenderer!" if id.nil?
        buffer = tag(:label, for: id) { element.attributes[:title] } + "\n"
        buffer + super
      end
    end

    class Button < SimpleInputRenderer
      def render
        tag(:button, element.attributes)
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
      def render
        if method = element.attributes[:method]
          set_method(method)
        end

        tag(:form, element.attributes) do
          element.elements.map do |element|
            element.render
          end.join("\n")
        end
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
