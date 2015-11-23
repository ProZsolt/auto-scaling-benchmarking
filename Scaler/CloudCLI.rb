#!/usr/bin/env ruby
require "thor"
require_relative "cloud_provision.rb"

class CloudCLI < Thor
  desc "run-scaler", "run scaler"
  def run_scaler
    CloudProvision.new.run_scaler
  end

  desc "scale-up", "scale up"
  def scale_up
    CloudProvision.new.scale_up
  end

  desc "scale-down", "scale down"
  def scale_down
    CloudProvision.new.scale_down
  end

  desc "set-capacity CAPACITY", "set capacity"
  def set_capacity capacity
    CloudProvision.new.set_capacity capacity
  end

  desc "get-capacity", "get capacity"
  def get_capacity
    puts CloudProvision.new.get_capacity
  end
end

CloudCLI.start(ARGV)
