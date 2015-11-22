require 'aws-sdk'

class Controller
  def initialize group_name
    Aws.config.update({region: ENV['AWS_REGION'] || 'eu-west-1'})
    @autoscaling = Aws::AutoScaling::Client.new
    @group_name = group_name
  end

  def get_capacity
    resp = @autoscaling.describe_auto_scaling_groups({
      auto_scaling_group_names: [@group_name],
      max_records: 1,
    })
    resp.auto_scaling_groups[0].desired_capacity
  end

  def set_capacity desired_capacity
    @autoscaling.set_desired_capacity({
      auto_scaling_group_name: @group_name,
      desired_capacity: desired_capacity,
      honor_cooldown: true,
    })
  end

  def scale_up (capacity = 1)
    set_capacity (get_capacity + capacity)
  end

  def scale_down (capacity = 1)
    set_capacity (get_capacity + capacity)
  end
end
