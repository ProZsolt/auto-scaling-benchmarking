class Pmean
  def initialize window
    @window = window
  end
  def predict metrics
    window = [@window, metrics.length].min
    metrics.last(window).inject(:+)/window
  end
end
