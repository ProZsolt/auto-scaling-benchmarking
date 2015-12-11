require_relative "monitor.rb"
require_relative "controller.rb"

class RuleBased
  def initialize monitor, controller, thr_up = 70, v_up = 180, in_up = 120, thr_down = 40, v_down = 180, in_down = 120
    @monitor = monitor
    @controller = controller
    @thr_up = thr_up
    @v_up = v_up
    @in_up = in_up
    @thr_down = thr_down
    @v_down = v_down
    @in_down = in_down
  end

  def scale
    target = "averageSeriesWithWildcards(collectd.*.cpu-0.cpu-user, 1)"
    data_up = @monitor.get_metric target v_up
    unless data_up.any?{|cpu| cpu[0] < thr_up}
      controller.scale_up
      sleep in_up
    else
      data_down = @monitor.get_metric target v_down
      unless data_down.any?{|cpu| cpu[0] > thr_down}
        controller.scale_down
        sleep in_down
      else
        sleep 60
      end
    end
  end
end
