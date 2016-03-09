require 'hookit/converginator'
require 'hookit/db'
require 'hookit/error'
require 'hookit/exit'
require 'hookit/helper'
require 'hookit/hook'
require 'hookit/logger'
require 'hookit/platform'
require 'hookit/registry'
require 'hookit/resource'
require "hookit/version"

module Hookit
  extend self

  def resources
    @resources ||= Hookit::Registry.new
  end

  def platforms
    @platforms ||= Hookit::Registry.new
  end
end

require 'hookit/resources'
require 'hookit/platforms'
