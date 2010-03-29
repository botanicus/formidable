# encoding: utf-8

require_relative "../spec_helper"

require "formidable/coercions"

describe "Formidable::Coercions" do
  base_class = Class.new do
    def self.to_s; "BaseClass"; end
    attr_accessor :raw_data, :cleaned_data
  end

  coercions_class = Class.new(base_class) do
    def self.to_s; "CoercionsClass"; end
    include Formidable::Coercions
  end

  describe ".coercions" do
    it "should have defined accessors" do
      Formidable::Coercions.coercions.should respond_to(:[])
      Formidable::Coercions.coercions.should respond_to(:[]=)
    end

    it "should raise MissingCoercion if there isn't any coercion for given key" do
      -> { Formidable::Coercions.coercions[:not_found] }.should raise_error(Formidable::Coercions::MissingCoercion)
    end
  end

  describe ".included" do
    before(:each) do
      @klass = Class.new
    end

    it "should fail if the class doesn't have method #raw_data nor #cleaned_data= defined" do
      -> { Class.new.send(:include, Formidable::Coercions) }.should raise_error(Formidable::Coercions::IncompatibleInterface)
    end

    it "should fail if the class doesn't have method #raw_data defined" do
      @klass.send(:attr_writer, :cleaned_data)
      -> { @klass.send(:include, Formidable::Coercions) }.should raise_error(Formidable::Coercions::IncompatibleInterface)
    end

    it "should fail if the class doesn't have method #cleaned_data= defined" do
      @klass.send(:attr_reader, :raw_data)
      -> { @klass.send(:include, Formidable::Coercions) }.should raise_error(Formidable::Coercions::IncompatibleInterface)
    end

    it "should pass otherwise" do
      @klass.send(:attr_accessor, :raw_data, :cleaned_data)
      -> { @klass.send(:include, Formidable::Coercions) }.should_not raise_error(Formidable::Coercions::IncompatibleInterface)
    end
  end

  describe "#coercions" do
    before(:each) do
      @instance = coercions_class.new
    end

    it "should have defined accessors" do
      @instance.coercions.should respond_to(:[])
      @instance.coercions.should respond_to(:[]=)
    end
  end
  
  describe "#coerce" do
    before(:each) do
      @instance = coercions_class.new
    end

    it "should fail with ArgumentError if both block and type are provided" do
      -> { @instance.coerce(:integer) { |value|  } }.should raise_error(ArgumentError)
    end

    it "should fail with ArgumentError if neither block nor type are provided" do
      -> { @instance.coerce }.should raise_error(ArgumentError)
    end

    it "should take a block as an argument and run it against the #raw_data" do
      @instance.coerce { |value| value.to_i }
    end

    it "should take a block as an argument and run it against" do
      @instance.coerce(:integer)
    end
    
    it "should -- not existing key" do
      -> { @instance.coerce(:class) }.should raise_error()
    end
  end

  describe "#coerce!" do
    before(:each) do
      @instance = coercions_class.new
    end

    it "should run all coercions against raw_data defined in the #raw_data method" do
    end

    it "should set #cleaned_data to the result of coercion" do
      @instance.coerce!
    end

    it "should be chainable, so the next coercion proc will receive the result of the previous on" do
    end
  end
end
