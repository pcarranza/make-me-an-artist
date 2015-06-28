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
  def parse
    pattern = /data-count="(?<count>\d+)" data-date="(?<date>\d{4}-\d{2}-\d{2})"/
    matched_values = @contributions_html.to_enum(:scan, pattern).map { Regexp.last_match }
    parsed_values = matched_values.map do |values|
      Contribution.new(values[:count], values[:date])
    end
  end
  def week(number)
    Week.new
  end
end

class Contribution
  attr_reader :count, :date
  def initialize(count, date)
    @count, @date = count, date
  end
end


class ContributionsParser
  def initialize(contributions)
    @contributions = contributions
  end
  def parse
    @contributions.to_enum(:scan, /data-count="(\d+)" data-date="(\d{4}-\d{2}-\d{2})"/)
    # .map { |value| value }
    # parsed_values = matched_values.map do |value|
    #   Contribution.new(count: value[1], date: value[2])
    # end

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
