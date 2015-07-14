class CommitRanges

  RANGE_NAMES = [:zero, :low, :mid, :high, :max]

  def initialize(**options)
    baseline = options.fetch(:contributions).baseline_commits
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

  def name_for(target_value)
    RANGE_NAMES[target_value]
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


class CommitPlan
  def initialize(commits)
    fail "Invalid commit list, expecting to find 7 lists" unless commits.length == 7
    @commit_days = commits
  end

  def week(week_of_year)
    weekdays = []
    @commit_days.each do |weeks|
      weekdays << weeks[week_of_year] || 0
    end
    weekdays
  end
end


class CommitPlanning
  def initialize(**options)
    @plan = options.fetch(:plan)
    @contributions = options.fetch(:contributions)
    @ranges = CommitRanges.new(contributions: @contributions)
  end

  def commits_for_date(date)
    fail "Invalid date" unless @contributions.is_valid_date?(date)
    return 0 if date < @contributions.first_commitable_date
    target = @ranges.name_for(@plan.week(week_for_date(date))[date.wday])
    @ranges.from(@contributions.find_by_date(date).count).bump_to(target)
  end

  def week_for_date(date)
    (date - @contributions.first_commitable_date).to_i / 7
  end
end
