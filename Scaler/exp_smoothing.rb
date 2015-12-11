require_relative "monitor.rb"
require_relative "controller.rb"

class ExpSmoothing
  def initialize monitor, controller, alpha = 0.7 omega = 8 thr_up = 70, thr_down = 40, cooldown = 120
    @monitor = monitor
    @controller = controller
    @alpha = alpha
    @omega = omega
    @thr_up = thr_up
    @thr_down = thr_down
    @cooldown = cooldown
  end

  def scale
    target = "averageSeriesWithWildcards(collectd.*.cpu-0.cpu-user, 1)"
    data = @monitor.get_metric target, (@omega+1)*30
    data = data.sort_by { |x| x[1] }.reverse
    pCPU = 0
    for i in 0..@omega
      pCPU = pCPU + @alpha * ((1-@alpha) ** i) * data[i][0]
    end

    if pCPU > thr_up
      controller.scale_up
      sleep cooldown
    elsif pCPU < thr_down
      controller.scale_down
      sleep cooldown
    elsif
      sleep 60
    end
  end
end
