require "faraday"
require "date"

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

  def contributions
    GithubContributions.new(github: self)
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
    @count, @date = count, Date.parse(date.to_s)
  end

  def ==(other)
    other.class == self.class && other.state == self.state
  end

  def first_day_of_week?
    date.sunday?
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

class GithubContributions
  include Enumerable

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

  def baseline_commits
    baseline = max.count * 2
    baseline = 10 * (baseline.to_f / (10 ** (Math.log10(baseline).ceil - 1))).ceil if baseline > 10
    baseline = 10 if baseline < 10
    baseline
  end

  def first_commitable_date
      @contributions[days_to_skip].date
  end

  def days_to_skip
    first_contribution = @contributions.first
    return 0 if first_contribution.first_day_of_week?
    7 - first_contribution.date.wday
  end

  def is_valid_date?(date)
    date >= @contributions.first.date && date <= @contributions.last.date
  end

  def find_by_date(date)
    @contributions[(date - first_commitable_date).to_i + days_to_skip] or Contribution.new(0, date)
  end

  def ==(other)
    other.class == self.class && other.state == self.state
  end

  protected

  def state
    [@contributions]
  end
end
