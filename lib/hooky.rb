require 'hooky/converginator'
require 'hooky/db'
require 'hooky/error'
require 'hooky/exit'
require 'hooky/helper'
require 'hooky/hook'
require 'hooky/logger'
require 'hooky/logvac'
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