require 'grape'
require 'datadog/statsd'
require 'socket'

if !defined? $statsd then
  $statsd = Datadog::Statsd.new(ENV['STATSD_HOST'] || "localhost", ENV['STATSD_PORT'] || 8125)
end

module Datadog
  module Grape
    class Middleware < ::Grape::Middleware::Base
      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        req = ::Rack::Request.new(env)
        request_path = request_path_in_datadog_format(env)
        host = "host:#{ENV['INSTRUMENTATION_HOSTNAME'] || Socket.gethostname}"
        method = "method:#{req.request_method}"
        path = "path:#{request_path}"
        tags = [host, method, path, "env:#{@options[:chef_env]}"]
        metric_name  = "grape.request"
        $statsd.time "#{metric_name}.time", :tags => tags do
          begin
            res = @app.call(env)
          rescue
            error = $!
            res = Rack::Response.new([ error.message ], 500, { 'Content-type' => 'text/error' }).finish
          end
          status, _, _ = res
          tags << "status:#{status}"
          $statsd.increment metric_name, :tags => tags
          status == 500 ? (raise error) : res
        end
      end

      private

      def request_path_in_datadog_format(env)
        path = env['api.endpoint'].routes.first.path[1..-1].gsub("/", ".").sub(/\(\.:format\)\z/, "").gsub(/\.:(\w+)/, '.{\1}')
        path.slice!('(.json)')
        path
      end
    end
  end
end
