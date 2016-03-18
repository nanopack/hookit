# This file is meant ONLY as a way to make a hookit hook directly executable.
#
# Normally hookit is bootstrapped via `hookit hook-name "payload"`.
#
# This script allows a ruby executable script to bootstrap hookit and run as
# a hook directly.
#
# Usage:
#
# #!/usr/bin/env ruby
#
# # optionally, set some configuration
# # (if not set, MODULE_ROOT will default to the directory if this script)
#
# $LOG_LEVEL = :error
# $LOGFILE = '/var/log/hookit/hookit.log'
# $MODULE_DIR = "/opt/local/hookit/mod"
#
# # load hookit/setup to bootstrap hookit
# require 'hookit/setup'
#
# execute 'list all the files!' do
#   command 'ls -lah /'
# end
#

# This won't handle every scenario, but essentially it tries to find the
# location of the script that was executed
hook = begin
  if $0[0] == '/'
    $0
  else
    "#{Dir.getwd}/#{$0}"
  end
end

module_dir = File.dirname(hook)

MODULE_DIR = $MODULE_DIR || ENV['MODULE_DIR'] || module_dir
LOG_LEVEL  = $LOG_LEVEL || ENV['LOG_LEVEL'] || :error
LOGFILE    = $LOGFILE || ENV['LOGFILE'] || '/var/log/hookit/hookit.log'

require 'hookit'
require 'json'

include Hookit::Hook   # payload helpers / resource dsl

set :log_level,   LOG_LEVEL
set :logfile,     LOGFILE
set :module_root, MODULE_DIR

# require hook libs
Dir.glob("#{MODULE_DIR}/lib/*.rb").each do |file|
  require file
end

logger.info ""
logger.info "hook: #{hook}"
logger.info "payload: #{payload.to_json}"
