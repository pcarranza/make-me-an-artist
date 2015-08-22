require_relative "github"
require_relative "planning"
require_relative "repo"

class Artist

  def initialize(username:, design:, repo_name: "noise", workdir: ".", **args)
    @username = username
    @design = design
    @github = args.fetch(:github) { Github.new(username: username) }
    @repo = args.fetch(:repo) { Repo.new(name: repo_name, workdir: workdir) }
    @start_date = args[:start_date]
    @commit_ranges = args[:commit_ranges]
  end

  def self.make_me_an_artist(**args)
    Artist.new(**args)
  end

  def now
    @repo.create
    calculator = CommitsPerDateCalculator.new(
      commit_plan: DesiredContributionsGraph.new(@design),
      contributions: @github.contributions,
      commit_ranges: @commit_ranges)
    calculator.each_date do |date, required_commits|
      next if @start_date and date < @start_date
      required_commits.times do
        @repo.run(Commit.new(date: date))
      end
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
