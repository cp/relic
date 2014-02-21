require 'relic/version'
require 'terminal-table'
require 'httparty'
require 'netrc'
require 'thor'

module Relic
  class CLI < Thor

    desc 'servers', 'provide a list of your servers'
    method_option :app, type: :string, aliases: '-a'
    def servers
      id       = credentials[0]
      api_key  = credentials[1]

      if options[:app]
        response = HTTParty.get("https://api.newrelic.com/api/v1/accounts/#{id}/applications/#{options[:app]}/servers.json", headers: {'x-api-key' => api_key})
      else
        response = HTTParty.get("https://api.newrelic.com/api/v1/accounts/#{id}/servers.json", headers: {'x-api-key' => api_key})
      end

      rows = Array.new
      response.each do |server|
        rows << [server['id'], server['hostname']]
      end

      title = (options[:app].nil? ? 'All servers' : "Servers for application ##{options[:app]}")

      puts Terminal::Table.new(title: title, headings: ['ID', 'Hostname'], rows: rows)
    end

    desc 'apps', 'provide a list of your applications'
    def apps
      rows = Array.new
      all_apps.each do |app|
        rows << [app['id'], app['name']]
      end

      puts Terminal::Table.new(headings: ['ID', 'Name'], rows: rows)
    end

    desc 'metrics', 'gather metrics for an application'
    method_option :app, type: :string, required: true, aliases: '-a'
    def metrics
      abort 'You must provide an app ID with the --app (-a) option.' if options[:app].nil?
      app_id = options[:app]
      metrics = HTTParty.get("https://api.newrelic.com/api/v1/accounts/#{credentials[0]}/applications/#{app_id}/threshold_values.json", headers: {'x-api-key' => credentials[1]})
      rows = Array.new

      metrics['threshold_values'].each do |metric|
        rows << [metric['name'], metric['formatted_metric_value']]
      end

      puts Terminal::Table.new(title: "App ##{app_id}", headings: ['Metric', 'Value'], rows: rows)
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

    # Get all of the user's apps.
    def all_apps
      HTTParty.get("https://api.newrelic.com/api/v1/accounts/#{credentials[0]}/applications.json", headers: {'x-api-key' => credentials[1]})
    end

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
