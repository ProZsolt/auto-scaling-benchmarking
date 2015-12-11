require_relative "monitor.rb"
require_relative "controller.rb"
require_relative "rule_based.rb"
require_relative "exp_smoothing.rb"

class CloudProvision
  def initialize
    @monitor = Monitor.new "bbdf6743/97ea2d09-8709-41b3-a9f7-b9d0da435bea"
    @controller = Controller.new "wordpress-WebServerGroup-1NGZTOQGAAR5A"
    @scaler = RuleBased.new @monitor, @controller
    #@scaler = ExpSmoothing.new @monitor, @controller
  end

  def run_scaler
    while true do
      @scaler.scale
    end
  end

  def scale_up
    @controller.scale_up
  end

  def scale_down
    @controller.scale_down
  end

  def set_capacity capacity
    @controller.set_capacity capacity
  end

  def get_capacity
    @controller.get_capacity
  end
end
