# encoding: utf-8

require "formidable/renderer"

module Formidable
  module Renderers
    class String < Renderer
      def tag(name, attributes = nil, &block)
        "<#{name}#{hash_to_attributes_string(attributes) if attributes}>#{block.call if block}</#{name}>"
      end

      def self_close_tag(name, attributes = nil)
        "<#{name}#{hash_to_attributes_string(attributes) if attributes} />"
      end

      protected
      def hash_to_attributes_string(hash)
        hash.inject(" ") do |buffer, pair|
          attribute, value = pair
          buffer += "attribute='#{value}'" # TODO: h(value)
          buffer
        end
      end
    end
  end
end
