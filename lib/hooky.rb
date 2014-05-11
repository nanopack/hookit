require 'hooky/converginator'
require 'hooky/db'
require 'hooky/dsl'
require 'hooky/error'
require 'hooky/exit'
require 'hooky/helpers'
require 'hooky/hook'
require 'hooky/registry'
require 'hooky/resource'
require "hooky/version"

module Hooky
  extend self

  def resources
    @resources ||= Hooky::Registry.new
  end
end

require 'hooky/resources'