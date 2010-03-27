# encoding: utf-8

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "formidable"
require "formidable/validations/presence"

class BasicForm < Formidable::Form
  text_field(:name, id: "basic_form-name").validate_presence.coerce { |value| value.to_i }
  text_field(:name, id: "basic_form-name").validate_presence.coerce(Integer) # converters[Integer].call
  submit("Save")
end
