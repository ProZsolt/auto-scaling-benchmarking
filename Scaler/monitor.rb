require 'aws-sdk'

class Monitor
  def initialize lb_name
    Aws.config.update({region: ENV['AWS_REGION'] || 'eu-west-1'})
    @as = Aws::AutoScaling::Client.new
    @cw = Aws::CloudWatch::Client.new
    @lb_name = lb_name
  end

  def fetch_cw_stats(namespace, metric_name, stats, dimensions)
    duration = 300
    begin
      stats = @cw.get_metric_statistics({
                    namespace: namespace,
                    metric_name: metric_name,
                    dimensions: dimensions,
                    start_time: (Time.now.utc - duration).iso8601,
                    end_time: Time.now.utc.iso8601,
                    period: 60,
                    statistics: stats
                    })
      if stats && stats[:datapoints] && stats[:datapoints][0] && stats[:datapoints][0][:timestamp]
        stats[:datapoints].sort!{|a,b| a[:timestamp] <=> b[:timestamp]}
      else
        return nil
      end

    rescue Exception => e
      puts "Error getting cloudwatch stats: #{metric_name} [skipping]"
      puts "Stats hash: #{stats_hash.inspect}" if @debug
      puts e.inspect
      return nil
    end
    stats
  end

  def fetch_elb_stats(lb_name, metric_name, stats)
    fetch_cw_stats("AWS/ELB", metric_name, stats, [{:name=>"LoadBalancerName", :value=>lb_name}])
  end

  def get_latency
    stats = fetch_elb_stats(lb_name, "Latency", ['Average'])
    stats[:datapoints][-1][:average] if stats
  end

  def get_request_count
    stats = fetch_elb_stats(lb_name, "RequestCount", ['Sum'])
    if stats
      return stats[:datapoints][-1][:sum].to_i
    else
      return 0
    end
  end

  def get_HTTPCode_Backend_2XX
    stats = fetch_elb_stats(lb_name, "HTTPCode_Backend_2XX", ['Sum'])
    stats[:datapoints][-1][:sum].to_i if stats
  end

  def get_HTTPCode_Backend_5XX
    stats = fetch_elb_stats(lb_name, "HTTPCode_Backend_5XX", ['Sum'])
    stats[:datapoints][-1][:sum].to_i if stats
  end

  def get_HTTPCode_ELB_5XX
    stats = fetch_elb_stats(lb_name, "HTTPCode_ELB_5XX", ['Sum'])
    stats[:datapoints][-1][:sum].to_i if stats
  end

  def get_backend_connection_errors
    stats = fetch_elb_stats(lb_name, "BackendConnectionErrors", ['Sum'])
    stats[:datapoints][-1][:sum].to_i if stats
  end

  def get_queue_length
    stats = fetch_elb_stats(lb_name, "SurgeQueueLength", ['Maximum'])
    stats[:datapoints][-1][:sum].to_i if stats
  end

  def get_spillover_count
    stats = fetch_elb_stats(lb_name, "SpilloverCount", ['Sum'])
    stats[:datapoints][-1][:sum].to_i if stats
  end
end
