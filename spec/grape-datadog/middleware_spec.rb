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

  it "should send an increment and  timing event for each request" do
    expect(defined? $statsd).not_to be nil
    $statsd.should_receive(:increment).with('grape.GET.echo.:key1.:key2')
    $statsd.should_receive(:timing) do |path, timing, _|
      path.should == 'grape.GET.echo.:key1.:key2.time'
      timing.should be > 1000
    end
    get "/echo/1/1234"
    last_response.status.should == 200
    last_response.body.should == "1 1234"
  end
end
