require 'net/http'
require 'uri'
require 'json'
require 'time'

class Monitor
  def initialize graphite_key
    @graphite_key = graphite_key
  end

  def get_metric target, from
    base_url = "https://www.hostedgraphite.com/"
    url_end = "/graphite/render?format=json"
    target_par = "&target=" + target
    from_par = "&from=-" + from.to_s + "second"
    cache_par = "&noCache=True"
    url = base_url + @graphite_key + url_end + target_par + from_par  + cache_par
    uri = URI.parse url
    response = Net::HTTP.get_response uri
    json = JSON.parse response.body
    json[0]['datapoints']
  end
end
