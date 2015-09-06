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

class RepoCommiter
  attr_reader :count
  def initialize(repo)
    @repo = repo
    @count = 0
  end
  def work(date, how_many)
    @repo.create
    how_many.times do
      @repo.run(Commit.new(date: date))
      @count += 1
    end
  end
end

class DryCommiter
  attr_reader :count
  def initialize(repo)
    @count = 0
  end
  def work(date, how_many)
    p "On #{date.to_s} we have to commit #{how_many} times"
    @count += how_many
  end
end
