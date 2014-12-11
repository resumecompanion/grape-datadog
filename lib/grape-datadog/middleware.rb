require 'grape'
require 'statsd'
require 'socket'

if !defined? $statsd then
  $statsd = Statsd.new(ENV['STATSD_HOST'] || "localhost", ENV['STATSD_PORT'] || 8125)
end

module Datadog
  module Grape
    class Middleware < ::Grape::Middleware::Base
      def initialize(app)
        @app = app
      end

      def call(env)
        req = ::Rack::Request.new(env)
        request_path = env['api.endpoint'].routes.first.route_path[1..-1].gsub("/", ".").sub(/\(\.:format\)\z/, "").gsub(/\.:(\w+)/, '.{\1}')
        host = "host:#{ENV['INSTRUMENTATION_HOSTNAME'] || Socket.gethostname}"
        method = "method:#{req.request_method}"
        path = "path:#{request_path}"
        tags = [host, method, path]

        metric_name  = "grape.request"
        $statsd.time "#{metric_name}.time", :tags => tags do
          res = @app.call(env)
          status, _, _ = res
          tags << "status:#{status}"
          $statsd.increment metric_name, :tags => tags
          res
        end
      end
    end
  end
end
