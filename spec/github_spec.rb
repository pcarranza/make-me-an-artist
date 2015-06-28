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

  it "builds with a username only" do
    github = Github.new(username: "pcarranza")
    expect(github).not_to be_nil
  end

  it "fetches contributions" do
    github = Github.new(username: "pcarranza", fetcher: fetcher)
    fetched_contributions = github.fetch_contributions
    expect(fetched_contributions).to eq contributions
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

describe "Contributions" do
  it "picks the maximun contribution from all" do
    contributions = Contributions.new(contributions: [
                                      Contribution.new(0, "2014-06-11"),
                                      Contribution.new(7, "2014-06-12"),
                                      Contribution.new(0, "2014-06-13"),
                                      Contribution.new(4, "2014-06-14")])
    expect(contributions.max).to eq Contribution.new(7, "2014-06-12")
  end
end

describe "CommitsPlanning" do
  let(:contributions) do
    [Contribution.new(0, "2014-06-01"),
      Contribution.new(9, "2014-06-02"),
      Contribution.new(4, "2014-06-03"),
      Contribution.new(1, "2014-06-04"),
      Contribution.new(0, "2014-06-05")]
  end
  let(:github) do
    Github.new(username: "username", contributions: contributions)
  end
  let(:commits_planning) do
    CommitsPlanning.new(contributions: contributions)
  end

  it "builds with a valid github" do
    planning = CommitsPlanning.new(github: github)
    expect(planning).not_to be_nil
  end

  it "builds with a valid contributions list" do
    planning = CommitsPlanning.new(contributions: contributions)
    expect(planning).not_to be_nil
  end

  it "calculates the commit ranges correctly" do
    expect(commits_planning.commit_ranges).to eq(0 => 0, 1 => 10, 2 => 20, 3 => 30, 4 => 40)
  end
  it "calculates the commit ranges fine with a larger ranges starting on the next tens" do
    planning = CommitsPlanning.new(contributions: [Contribution.new(23, "2014-06-01")])
    expect(planning.commit_ranges).to eq(0 => 0, 1 => 30, 2 => 60, 3 => 90, 4 => 120)
  end

  it "calculates the commit ranges fine with a larger ranges also on the tens" do
    planning = CommitsPlanning.new(contributions: [Contribution.new(30, "2014-06-01")])
    expect(planning.commit_ranges).to eq(0 => 0, 1 => 40, 2 => 80, 3 => 120, 4 => 160)
  end

end
