require "faraday"

class Github
  def initialize(**options)
    @contributions_fetcher = options.fetch(:fetcher) do
      ContributionsFetcher.new(username: options.fetch(:username))
    end
    @contributions = options[:contributions]
  end

  def fetch_contributions
    @contributions ||= @contributions_fetcher.fetch
  end
end

class Contributions
  def initialize(**options)
    @contributions = options.fetch(:contributions) do
      options.fetch(:github).fetch_contributions
    end
  end

  def max
    @max ||= @contributions.max_by(&:count)
  end

  def each
    @contributions.each do |contribution|
      yield contribution
    end
  end
end

class CommitsPlanning
  def initialize(**options)
    @contributions = Contributions.new(options)
  end

  def commit_ranges
    return @commit_ranges if @commit_ranges
    max_contribution = @contributions.max.count + 1
    max_contribution = 10 * (max_contribution.to_f / (10 ** (Math.log10(max_contribution).ceil - 1))).ceil if max_contribution > 10
    @commit_ranges = (0..4).map { |index| [index, (max_contribution) * index] }.to_h
  end

  private
  def baseline

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
