# encoding: utf-8

begin
  require "nokogiri"
rescue LoadError
  raise LoadError, "You have to install nokogiri gem if you want to use nokogiri renderer!"
end

module Formidable
  module Renderers
    class Nokogiri < Renderer
      register(Form) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end

      register(Elements::TextField) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end

      register(Elements::TextArea) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end

      register(Elements::HiddenField) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end

      register(Elements::Submit) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end

      register(Elements::Button) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end
      
      register(Elements::Group) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end
      
      register(Elements::Fieldset) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end
      
      register(Elements::FileField) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end
      
      register(Elements::EmailField) do |element|
        raise NotImplemented, "We'll implement the renderer soon"
      end
    end
  end
end
