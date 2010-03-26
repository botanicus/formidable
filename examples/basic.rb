# encoding: utf-8

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "formidable"

class BasicForm < Formidable::Form
  text_field(:name)
  submit("Save")
end
