require 'spec_helper'

describe Datadog::Grape::Middleware do

  class TestAPI < Grape::API
    use Datadog::Grape::Middleware
    get 'echo/:key1/:key2' do
      sleep 1
      "#{params['key1']} #{params['key2']}"
    end
  end

  def app; TestAPI; end

  it "should send an increment and timing event for each request" do
    expect(defined? $statsd).not_to be nil
    $statsd.should_receive(:increment) do |name, params|
      name.should == 'grape.request'
      expect(params[:tags]).to include('method:GET', 'status:200', 'path:echo.{key1}.{key2}')
    end
    $statsd.should_receive(:timing) do |name, timing, params|
      name.should == 'grape.request.time'
      timing.should be > 1000
      expect(params[:tags]).to include('method:GET', 'status:200', 'path:echo.{key1}.{key2}')
    end

    get "/echo/1/1234"
    last_response.status.should == 200
    last_response.body.should == "1 1234"
  end
end
