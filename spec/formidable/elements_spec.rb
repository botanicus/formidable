# encoding: utf-8

require_relative "../spec_helper"
require_relative "../../examples/basic"

describe "Formidable::Elements" do
  before(:each) do
    @form = BasicForm.new(action: "/create", method: "POST")
  end

  describe "#renderer" do
    it "should be an object responding to #render method" do
      # @form.renderer.should respond_to(:render)
    end
  end

  describe "#render" do
    it "should call the #call method on renderer" do
    end
  end
end
