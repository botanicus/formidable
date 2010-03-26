# encoding: utf-8

# class MyRenderer < Formidable::Renderer
#   def call(e)
#     Nokokogiri::Node.new(e)
#   end
# end
#
# renderer = Formidable::Renderer::Nokogiri.new
# renderer.register(TextField, MyRenderer.new)
# renderer.render(Formidable::Form.new(:user, :password))

module Formidable
  module Renderers
    RendererNotRegistered = Class.new(StandardError)

    class Renderer
      class << self; attr_accessor :renderers; end
      @renderers = Hash.new do |hash, key|
        raise RendererNotRegistered.new("Renderer for #{key} isn't registered yet!")
      end

      def self.register(klass, renderer = nil, &block)
        if renderer && block
          raise ArgumentError, "You have to provide renderer or a block, not both of them!"
        elsif renderer.nil? && block
          @renderers[klass] = block
        else
          @renderers[klass] = renderer
        end
      end

      def self.inherited(subclass)
        subclass.renderers = renderers.dup
      end

      def render(element)
        # self[element.class].call(element)
        proc = self[element.class]
        self.instance_exec(element, &proc)
      end

      def [](klass)
        klass.ancestors.each do |ancestor|
          if ancestor.is_a?(Class) && self.class.renderers.has_key?(ancestor)
            return self.class.renderers[ancestor]
          end
        end
      end
    end
  end
end
