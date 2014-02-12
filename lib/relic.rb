require "relic/version"
require "terminal-table"
require "httparty"
require "netrc"
require "thor"

module Relic
  class CLI < Thor

    desc 'servers', 'provide a list of your servers'
    def servers
      id       = credentials[0]
      api_key  = credentials[1]
      response = HTTParty.get("https://api.newrelic.com/api/v1/accounts/#{id}/servers.json", headers: {'x-api-key' => api_key})

      rows = Array.new
      response.each do |server|
        rows << [server['id'], server['hostname']]
      end

      puts Terminal::Table.new(headings: ['ID', 'Host Name'], rows: rows)
    end

    desc 'auth', 'authenticate with the New Relic API'
    def auth
      puts 'Please enter your New Relic API key and hit enter.'
      api_key = STDIN.gets.chomp
      puts 'Retrieving your account ID...'
      id = account_id(api_key)
      n = Netrc.read
      n.new_item_prefix = "# Added by the Relic CLI.\n"
      n["api.newrelic.com"] = id, api_key
      n.save
      puts "You have been authenticated!"
    end

  private

    # Given an API key, reach out to the New Relic API to grab the account ID.
    #
    # @see http://newrelic.github.io/newrelic_api/#label-Account+ID
    #
    # @param [String] New Relic API key.
    # @return [Integer] account ID.
    # @abort if New Relic doesn't return a 200.
    def account_id(key)
      response = HTTParty.get('https://api.newrelic.com/api/v1/accounts.xml', headers: {'x-api-key' => key})

      if response.code == 200
        response['accounts'].first['id'] # There may be a case where a user has more than one account?
      else
        abort "There was an error. Was your API key correct?"
      end
    end

    # Retrieves New Relic credentials from ~/.netrc.
    #
    # @return [Array] array of two elements: account ID and API key.
    # @abort if user hasn't authenticated.
    def credentials
      n = Netrc.read
      auth = n["api.newrelic.com"]

      if auth.nil?
        abort "Plese authenticate first."
      else
        auth
      end
    end
  end
end
