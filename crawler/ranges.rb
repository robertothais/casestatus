require './range_finder'
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.join(File.dirname(__FILE__), 'db', 'ranges.db'))

module RangeQueries
  def vermont
    where center: 'EAC'
  end

  def california
    where center: 'WAC'
  end

  def year(year)
    where year: year
  end
end

class YearRange < ActiveRecord::Base
  extend RangeQueries
  validates_presence_of :center, :year, :days

  def self.recalculate(center, range)
    RangeFinder.years(center, range) do |year, days|
      obj = YearRange.find_or_initialize_by_center_and_year(center, year)
      if !obj.days.present? || obj.days < days
        obj.days = days
        obj.save!
      end
    end
  end
end

class DayRange < ActiveRecord::Base
  extend RangeQueries
  validates_presence_of :center, :year, :day, :cases

  # Excludes days for which we already information
  def self.fill(center, year, day_range = :all)
    recalculate center, year, day_range, DayRange.year(year).map(&:day)
  end

  def self.recalculate(center, year, day_range = :all, exclude = [])
    if day_range == :all
      begin
        tries = 0
        year_data = YearRange.find_by_center_and_year!(center, year)
        day_range = 1...year_data.days
      rescue ActiveRecord::RecordNotFound
        YearRange.recalculate(center, year..year) unless year.present?
        tries += 1
        retry unless tries >= 1
      end       
    end
    RangeFinder.days(center, year, day_range, exclude) do |day, last_case|
      obj = DayRange.find_or_initialize_by_center_and_year_and_day(center, year, day)
      new_value = last_case.id - 50_000
      # Only save if the new value is higher
      if !obj.cases.present? || obj.cases < new_value
        obj.cases = new_value
        obj.save!
      end
    end
  end
end