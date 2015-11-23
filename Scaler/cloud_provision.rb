#!/usr/bin/env ruby

#require_relative
require 'thor'
require 'monitor.rb'
require 'controller.rb'
require 'predictor.rb'
require 'mean.rb'
class CloudProvision < Thor
  def initialize
    @metrics = []
    @monitor = Monitor.new 'WordPress-ElasticL-ZK36H53W0LQZ'
    @predictor = Pmean.new 8
    @controller = Controller.new 'WordPress-sample-scalable-WebServerGroup-19PVWDVMFLKMZ'
  end

  def run
    while true do
      @metrics.push(@monitor.get_request_count)
      prediction = @predictor.predict (@metrics)
      p prediction
      @controller.set_capacity ((prediction/(7.0*300.0)).ceil)
      sleep 5.minutes
    end
  end
end
