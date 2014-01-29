require "relic/version"
require "terminal-table"
require "httparty"
require "netrc"
require "thor"

module Relic
  class CLI < Thor

    desc 'servers', 'provide a list of your servers'
    def servers
      puts "Hello world!"
    end
  end
end
