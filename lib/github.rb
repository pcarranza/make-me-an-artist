require "faraday"

class Github
  def initialize(**options)
    @username = options.fetch(:username)
    @github_contributions = options.fetch(:contributions) { Contributions.new(@username) }
  end
  def fetch_contributions
    @github_contributions.fetch
  end
end

class Contributions
  def initialize(**options)
    @connection = options.fetch(:connection) do
      Faraday.new(url: "https://github.com/users/#{options.fetch(:username)}/contributions") do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end
  end
  def fetch
    @contributions = ContributionsParser.new.parse(@connection.get.body)
  end
  def [](index)
    @contributions[index]
  end
end

class Contribution
  attr_reader :count, :date
  def initialize(count, date)
    @count, @date = count, date
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
