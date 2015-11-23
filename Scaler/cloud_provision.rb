require_relative "monitor.rb"
require_relative "controller.rb"
require_relative "predictor.rb"
require_relative "mean.rb"

class CloudProvision
  def initialize
    @metrics = []
    @monitor = Monitor.new 'WordPress-ElasticL-ZK36H53W0LQZ'
    @predictor = Pmean.new 8
    @controller = Controller.new 'WordPress-sample-scalable-WebServerGroup-19PVWDVMFLKMZ'
  end

  def run_scaler
    while true do
      @metrics.push(@monitor.get_request_count)
      p @metrics
      prediction = @predictor.predict (@metrics)
      p prediction
      @controller.set_capacity ((prediction/(7.0*300.0)).ceil)
      sleep 300
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
