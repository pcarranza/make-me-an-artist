require "spec_helper"

describe "Github" do
  it "fetches contributions" do
    contributions = double()
    allow(contributions).to receive(:fetch).and_return(:sentinel)
    github = Github.new(username: "pcarranza", fetcher: contributions)
    github_contributions = github.fetch_contributions
    expect(github_contributions).to eq :sentinel
  end
end

describe "ContributionsFetcher" do
  let(:connection) do
    connection, response = double(), double()
    allow(connection).to receive(:get).and_return(response)
    allow(response).to receive(:body).and_return(Factories.contributions_html)
    connection
  end

  it "fetchs contributions as a Contribution list" do
    fetcher = ContributionsFetcher.new(connection: connection)
    contributions = fetcher.fetch
    expect(contributions[0]).to eq(Contribution.new(0, "2014-06-27"))
    expect(contributions[11]).to eq(Contribution.new(7, "2014-07-08"))
    expect(contributions[15]).to eq(Contribution.new(4, "2014-07-12"))
  end
end
