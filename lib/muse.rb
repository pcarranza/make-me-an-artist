require_relative "github"
require_relative "planning"

class Muse

  def initialize(username:, design:, repo_name: "noise", workdir: ".", **args)
    @username = username
    @design = design
    @github = args.fetch(:github) { Github.new(username: username) }
    @start_date = args[:start_date]
    @commit_ranges = args[:commit_ranges]
  end

  def make_me_an_artist
    calculator = CommitsPerDateCalculator.new(
      commit_plan: DesiredContributionsGraph.new(@design),
      contributions: @github.contributions,
      commit_ranges: @commit_ranges)
    calculator.each_date do |date, required_commits|
      next if @start_date and date < @start_date
      yield date, required_commits
    end
  end

end

class Design

  def initialize(skip_weeks: 0)
    @design = 7.times.inject([]) do |week|
      week << []
    end
    @skip_weeks = skip_weeks
  end

  def add(design)
    7.times do |day|
      @design[day] += design[day]
    end
    self
  end

  def create
    design = @design.clone
    @skip_weeks.times do
      7.times do |day| design[day].shift end
    end
    design
  end

end

