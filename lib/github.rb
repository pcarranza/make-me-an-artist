require "faraday"

class Github
  def initialize(**options)
    @username = options.fetch(:username)
    @github_contributions = options.fetch(:contributions, GithubContributions.new(@username))
  end
  def fetch_contributions
    @github_contributions.fetch
  end
end

class GithubContributions
  def initialize(username, **options)
    @connection = options.fetch(:connection) do
      Faraday.new(url: "https://github.com/users/#{username}/contributions") do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end
  end
  def fetch
    @contributions_html = @connection.get.body
  end
  def week(number)
    Week.new
  end
end

class Week
  def day(day_of_week)
    case day_of_week
    when 0, 1, 3, 4, 5
      0
    when 2
      7
    when 6
      4
    end
  end
end
