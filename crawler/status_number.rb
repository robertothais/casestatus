class StatusNumber

  BASE_ID = 50001
  BASE_DAY = 1

  attr_accessor :day, :id, :status

  def initialize(center, year, day, id)
    @center, @year, @day, @id = center, year, day, id
  end

  def to_s
    "#{@center}#{@year.to_s[-2,2]}#{'%03d' % @day}#{@id}"
  end

  def self.parse
  end
  
end