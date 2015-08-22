require_relative "github"
require_relative "planning"
require_relative "repo"

class Artist

  def initialize(username:, desired_graph:, repo_name: "noise", workdir: ".")
    @username = username
    @github = Github.new(username: username)
    @repo = Repo.new(name: repo_name, workdir: workdir).create
    @desired_graph = desired_graph
  end

  def self.make_me_an_artist(**args)
    Artist.new(**args)
  end

  def now
    calculator = CommitsPerDateCalculator.new(
      commit_plan: WantedContributionsGraph.new(@desired_graph),
      contributions: @github.contributions)
    calculator.each_date do |date, required_commits|
      required_commits.times do
        @repo.run(Commit.new(date: date))
      end
    end
  end

end
