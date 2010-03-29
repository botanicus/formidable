# encoding: utf-8

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "formidable"
require "formidable/validations/presence"

class BasicForm < Formidable::Elements::Form
  def setup(&block)
    text_field(:name, id: "basic_form-name")
      .validate_presence
      .coerce { |value| value.to_i }
    
    text_field(:rating, id: "basic_form-rating")
      .validate_presence
      .coerce(Integer)
    
    fieldset(:i_brake_it) do
      legend("yyyy", id: 'xxx')
      text_field(:nono, id: "nono").validate_presence
    end
    
    group(:i_m_group) do
      text_field(:groupa, id: 'xy')
    end
    block.call if block
    submit("Save")
  end
  
  def save
    
  end
end

class MyForm < BasicForm
  def setup
    super do
      text_field(:super_duper, id: 'super_duper')
    end
  end
end
