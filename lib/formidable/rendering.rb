# encoding: utf-8

module Formidable
  module Rendering
    RendererNotAssigned = Class.new(StandardError)

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.extend Module.new {
        def inherited(subclass)
          subclass.renderer(default_renderer)
        end
      }
    end

    attr_writer :renderer
    def renderer
      @renderer ||= begin
        renderer = self.class.default_renderer
        renderer.new(self) unless renderer.nil?
      end
    end

    def render
      if renderer.nil?
        raise RendererNotAssigned, "You have to assign renderer. You can set default_renderer via #{self.class}.renderer(renderer_class) or you can set renderer per instance via #renderer=(renderer_instance) method."
      elsif renderer && ! renderer.respond_to?(:render)
        raise RendererNotAssigned, "You assigned #{self.renderer.inspect} to the #{self.inspect}, but it doesn't respond to #render method"
      else
        renderer.render
      end
    end

    module ClassMethods
      attr_reader :default_renderer

      def renderer(default_renderer)
        @default_renderer = default_renderer
      end
    end
  end
end
