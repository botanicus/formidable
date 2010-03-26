# encoding: utf-8

begin
  require File.expand_path("../.bundle/environment", __FILE__)
rescue LoadError
  require "bundler"
  Bundler.setup
end

require "spec"

# setup load paths
$:.unshift(File.expand_path("../lib", __FILE__))
