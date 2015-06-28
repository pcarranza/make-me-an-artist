require "faraday"
require "forwardable"

class Github
  attr_reader :contributions, :max_contribution
  def initialize(**options)
    @contributions_fetcher = options.fetch(:fetcher) do
      ContributionsFetcher.new(options.fetch(:username))
    end
  end

  def fetch_contributions
    @contributions = @contributions_fetcher.fetch
    @max_contribution = @contributions.max_by(&:count)
  end
end

class ContributionsFetcher
  def initialize(**options)
    @connection = options.fetch(:connection) do
      Faraday.new(url: "https://github.com/users/#{options.fetch(:username)}/contributions") do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end
  end

  def fetch
    ContributionsParser.new.parse(@connection.get.body)
  end
end

class Contribution
  attr_reader :count, :date

  def initialize(count, date)
    @count, @date = count, date
  end

  def ==(other)
    other.class == self.class && other.state == self.state
  end

  protected

  def state
    [count, date]
  end
end

class ContributionsParser
  def initialize
    @pattern = /data-count="(?<count>\d+)" data-date="(?<date>\d{4}-\d{2}-\d{2})"/
  end

  def parse(html)
    html.to_enum(:scan, @pattern).map { Regexp.last_match }.map do |values|
      Contribution.new(values[:count].to_i, values[:date])
    end
  end
end
