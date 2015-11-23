class Pmax
  def initialize window
    @window = window
  end
  def predict metrics
    window = [@window, metrics.length]
    metrics.last(window).max
  end
end
