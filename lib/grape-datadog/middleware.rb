require 'grape'
require 'statsd'

if !defined? $statsd then
  $statsd = Statsd.new
end

module Datadog
  module Grape
    class Middleware < ::Grape::Middleware::Base
      def initialize(app)
        @app = app
      end

      def call(env)
        req = ::Rack::Request.new(env)
        request_path = env['api.endpoint'].routes.first.route_path[1..-1].gsub("/", ".").sub(/\(\.:format\)\z/, "") 
        metric_name  = "grape.#{req.request_method}.#{request_path}"
        $statsd.increment(metric_name)
        $statsd.time("#{metric_name}.time") do
          @app.call(env)
        end
      end
    end
  end
end
