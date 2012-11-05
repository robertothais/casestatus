require './status_number'
require './status'

class RangeFinder

  def self.years(center, year_range)
    days = year_range.map do |year|
      base_number = StatusNumber.new(center, year, StatusNumber::BASE_DAY, StatusNumber::BASE_ID)
      number = base_number.clone
      number.day = 365
      result = search(number, base_number, :day)
      if result
        yield(year, result.day) if block_given?
        result.day
      else nil
      end
    end
    Hash[year_range.zip(days)]
  end

  def self.days(center, year, day_range, exclude = [])
    numbers = day_range.map do |day|
      next if exclude.include?(day)
      # Increment in steps of 1000 to find an out of bounds number
      base_number = StatusNumber.new(center, year, day, StatusNumber::BASE_ID)
      number = base_number.clone
      status = Status.get number
      # Assume that if the first case isn't valid, then none for that day are
      next unless status.valid?
      while status.valid? do
        number.id = number.id + 1000
        status = Status.get number
      end
      result = search(number, base_number, :id)        
      if result
        yield(day, result) if block_given?
      else nil
      end
    end
    Hash[day_range.zip(numbers)]
  end

  # Binary search
  def self.search(upper, lower, segment)
    puts "#{upper} #{lower}"
    if upper.send(segment) == lower.send(segment) + 1
      if lower.status.valid?
        puts "Found: #{lower}"
        return lower 
      else
        puts 'No case status found'
        return nil
      end
    end
    midpoint = lower.clone
    midpoint.send(:"#{segment}=", midpoint.send(segment) + ((upper.send(segment) - lower.send(segment)) / 2))
    status = Status.get midpoint
    midpoint.status = status
    if status.valid?
      lower = midpoint
    else
      upper = midpoint
    end
    search(upper, lower, segment)
  end
end