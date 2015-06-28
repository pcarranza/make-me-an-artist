require "spec_helper"

describe "Github" do
  it "fetches contributions" do
    contributions = double()
    allow(contributions).to receive(:fetch).and_return(:sentinel)
    github = Github.new(username: "pcarranza", contributions: contributions)
    github_contributions = github.fetch_contributions
    expect(github_contributions).to eq :sentinel
  end
end

describe "Contributions" do
  let(:connection) do
    connection, response = double(), double()
    allow(connection).to receive(:get).and_return(response)
    allow(response).to receive(:body).and_return(Factories.contributions_html)
    connection
  end

  it "fetchs and parses contributions" do
    contributions = Contributions.new(connection: connection)
    contributions.fetch
    expect(contributions[0].date).to eq("2014-06-27")
    expect(contributions[0].count).to eq(0)
  end
end
