#!/usr/bin/env ruby

require "thor"
require "json"

class JujuProvision < Thor

  MAX_INSTANCES = 5

  desc "bootstrap", "bootstraps wordpress"
  def bootstrap
    system 'juju bootstrap'
    system 'juju deploy mysql'
    system 'juju deploy wordpress'
    system 'juju add-relation wordpress mysql'
    system 'juju set wordpress wp-content=http://github.com/marcoceppi/wordpress-demo.git'
    system 'juju set wordpress tuning=optimized'
    system 'juju expose wordpress'
  end

  desc "scale_out", "scale out app servers"
  def scale_out
    if units.length >= MAX_INSTANCES
      puts "The maximum number of instances are running"
    else
      system 'juju add-unit wordpress'
    end
  end

  desc "scale_in", "scale in app servers"
  def scale_in
    if units.length > 1
      unit = units[-1].key
      system "juju remove-unit #{unit}"
    else
      puts "Only one instance is running"
    end
  end

  desc "terminate", "terminate environment"
  def terminate
    system 'juju destroy-environment amazon'
  end

  desc "get_metrics", "get metrics(work in progress)"
  def get_metrics
    metrics = []
    units.each do |unit|
      metrics += %x[juju ssh #{unit.key} top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%*id.*/\1/" | awk '{print 100 - $1}']
    end
    metrics
  end

  def units
    units = JSON.parse(%x[juju status --format=json])['services']['wordpress']['units']
    if units.kind_of?(Array)
      units
    else
      [units]
    end
  end

  desc "status", "get status of the stack"
  def status
    state = JSON.parse %x[juju status --format=json]
    state['services'].each do |k, v|
      puts k
      v['units'].each do |uk, uv|
        puts "  #{uk} #{uv['agent-state']}"
      end
    end
  end
end

JujuProvision.start(ARGV)
