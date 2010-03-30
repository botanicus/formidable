#!/usr/bin/env gem build
# encoding: utf-8

# Run ./form.gemspec or gem build form.gemspec
# NOTE: we can't use require_relative because when we run gem build, it use eval for executing this file
require File.expand_path("../lib/formidable/version", __FILE__)
require "base64"

Gem::Specification.new do |s|
  s.name = "formidable"
  s.version = Formidable::VERSION
  s.authors = ["Jakub Stastny aka Botanicus", "Pavel Kunc"]
  s.homepage = "http://github.com/botanicus/formidable"
  s.summary = "" # TODO: summary
  s.description = "" # TODO: long description
  s.cert_chain = nil
  Base64.decode64("c3Rhc3RueUAxMDFpZGVhcy5jeg==\n")
  s.has_rdoc = true

  # files
  s.files = `git ls-files`.split("\n")

  s.require_paths = ["lib"]

  # Ruby version
  s.required_ruby_version = ::Gem::Requirement.new(">= 1.9")

  begin
    require "changelog"
  rescue LoadError
    warn "You have to have changelog gem installed for post install message"
  else
    s.post_install_message = CHANGELOG.new.version_changes
  end

  # RubyForge
  s.rubyforge_project = "formidable"
end
