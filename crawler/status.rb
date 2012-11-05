require 'nokogiri'
require 'uri'
require 'typhoeus'
require 'active_support/core_ext/string/filters'

class Status

  attr_reader :doc, :html, :number

  SERVICE_URL = 'https://egov.uscis.gov/cris/Dashboard/CaseStatus.do'
  PARAM_NAME  = 'appReceiptNum'

  def self.request(status_number)
    Typhoeus::Request.new SERVICE_URL, 
      method: 'post', 
      body: "#{PARAM_NAME}=#{status_number.to_s}"
  end

  def self.get(status_number)
    res = Typhoeus::Request.post SERVICE_URL,
      params: { PARAM_NAME => status_number.to_s }
    new res.body, status_number
  end

  def initialize(html, number, check_rate_limited = true)
    @doc, @html, @number = Nokogiri::HTML(html), html, number
    raise RateLimitedError if check_rate_limited && rate_limited?
  end

  def state
    @doc.css('.caseStatusInfo > h4').text.squish
  end

  def info
    @doc.css('.caseStatus').text.squish
  end

  def valid?
    @doc.css('.errorContainer').empty? && !rate_limited?
  end

  # Matches this message:
  # It was reported to us that your IP address or internet gateway has been 
  # locked out for a select period of time.  This is due to an unusually high rate of use.
  # In order to avoid this issue, please create a Customer account (single applicant) or 
  # a Representative account (representing many individuals).
  def rate_limited?
    @doc.css('.workAreaMessage b.error').text.include?('locked')
  end

end

class RateLimitedError < Exception
  def initialize
    super 'We have been rate limited'
  end
end