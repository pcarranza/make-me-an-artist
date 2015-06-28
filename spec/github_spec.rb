require "spec_helper"

describe "Github" do
  it "fetches contributions" do
    sentinel = double("sentinel")
    contributions = double("contributions")
    allow(contributions).to receive(:fetch).and_return(sentinel)
    github = Github.new username: "pcarranza", contributions: contributions
    github_contributions = github.fetch_contributions
    expect(github_contributions).to eq sentinel
  end
end

describe "GithubContributions" do

  let(:connection) do
    connection, response = double(), double()
    allow(connection).to receive(:get).and_return(response)
    allow(response).to receive(:body).and_return($contributions_html)
    connection
  end

  it "fetches contributions" do
    contributions = GithubContributions.new("my_user", connection: connection)
    expect(contributions.fetch).not_to be_nil
  end
  it "parses the fetched contributions" do
    contributions = GithubContributions.new("my_user", connection: connection)
    contributions.fetch
    expect(contributions.week(1).day(1)).to eq(0)
    expect(contributions.week(2).day(2)).to eq(7)
    expect(contributions.week(2).day(6)).to eq(4)
  end
end
