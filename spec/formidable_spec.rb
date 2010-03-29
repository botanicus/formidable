# encoding: utf-8

require_relative "spec_helper"
require_relative "../examples/basic"

# TODO: odstranovani elementu (accessory)
describe "Formidable" do
  before(:each) do

  end

  describe "#renderer" do
    it "should be an object responding to #render method" do
      # @form.renderer.should respond_to(:render)
    end
  end

  describe "#render" do
    it "should call the #render method on renderer" do
      #params = {rating: "3"} # validations
      params = {name: "Hello", rating: 3}
      # params = {name: "Hello", rating: 3, :i_brake_it => {nono: 'test'}}
      @form = BasicForm.new(:my_form, {action: "/create", method: "POST"}, params)

      puts @form.inspect
      puts "=== RENDER ==="
      puts @form.render

      puts "\n=== VALID? ==="
      puts @form.valid?
      
      puts "\n=== ERRORS ==="
      p @form.errors

      puts "\n=== ACCESSORS ==="
      puts @form.rating.raw_data
      puts @form.name.raw_data
      puts @form.i_brake_it.raw_data.inspect
      puts @form.i_brake_it.nono.raw_data
      
      puts @form.i_brake_it.nono.raw_data = "NOTEST"
      puts @form.i_brake_it.raw_data.inspect
      # puts @form.submit
      
      puts '=' * 80
      @form1 = MyForm.new(:test_form)
      puts @form1.render
      p @form1.errors
    end
  end
end
