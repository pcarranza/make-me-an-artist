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

class Contributions
  include Enumerable

  def initialize(**options)
    @contributions = options.fetch(:contributions) do
      options.fetch(:github).fetch_contributions
    end
  end

  def max
    @max ||= @contributions.max_by(&:count)
  end

  def baseline_commits
    baseline = max.count + 1
    baseline = 10 * (baseline.to_f / (10 ** (Math.log10(baseline).ceil - 1))).ceil if baseline > 10
    baseline = 10 if baseline < 10
    baseline
  end
end

class CommitRanges

  RANGE_NAMES = [:zero, :low, :mid, :high, :max]

  def initialize(**options)
    baseline = Contributions.new(options).baseline_commits
    @commit_ranges = RANGE_NAMES.each_with_index.map {|range_name, index|
      [range_name, (baseline) * index]
    }.to_h
    @one_less_map = RANGE_NAMES.each_with_index.map {|range_name, index|
      [range_name, RANGE_NAMES[index - 1]]
    }.to_h
    @one_less_map.delete(:zero)
  end

  def [](range_name)
    @commit_ranges[range_name]
  end

  def from(commit_count)
    RangeFinder.new(self, commit_count)
  end

  def one_less_than(range)
    @one_less_map[range]
  end

  def range_pair(target_range)
    min_range = one_less_than(target_range)
    RangePair.new(min_range, target_range)
  end

  def to_h
    RANGE_NAMES.each_with_index.map {|range_name, index|
      [index, @commit_ranges[range_name]]
    }.to_h
  end
end

class RangePair
  attr_reader :low, :high
  def initialize(low, high)
    @low, @high = low, high
  end

  def ==(other)
    other.class == self.class && other.state == self.state
  end

  protected

  def state
    [low, high]
  end
end

class RangeFinder
  def initialize(ranges, commit_count)
    @ranges = ranges
    @commit_count = commit_count
  end

  def bump_to(target_range)
    pair = @ranges.range_pair(target_range)
    return 0 if in_current_range?(pair)
    minimum_required(pair)
  end

  def in_current_range?(pair)
    @commit_count > @ranges[pair.low] && @commit_count < @ranges[pair.high]
  end

  def minimum_required(pair)
    @ranges[pair.low] + 1 - @commit_count
  end
end
