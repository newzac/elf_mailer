#!/usr/bin/env ruby

require_relative "config/environment"
require_relative "lib/match"

ElfMailer::Match.run_until_matched
