# Match Found
class MatchFoundException < StandardError
  attr_accessor :data

  def initialize(data)
    self.data = data
  end
end