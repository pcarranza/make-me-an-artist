require "spec_helper"

describe "Github" do
  let (:contributions) do
    [Contribution.new(1, "2014-06-12"), Contribution.new(0, "2014-06-13")]
  end
  let (:fetcher) do
    fetcher = double()
    allow(fetcher).to receive(:fetch).and_return(contributions)
    fetcher
  end

  it "fetches contributions" do
    github = Github.new(username: "pcarranza", fetcher: fetcher)
    github.fetch_contributions
    expect(github.contributions).to eq contributions
  end

  it "picks the maximun contribution" do
    github = Github.new(username: "pcarranza", fetcher: fetcher)
    github.fetch_contributions
    expect(github.max_contribution).to eq Contribution.new(1, "2014-06-12")
  end

  it "fails without a username or fetcher" do
    expect { Github.new }.to raise_error(KeyError)
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
