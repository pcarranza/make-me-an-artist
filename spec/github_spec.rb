require "spec_helper"

describe Github do
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

  it "returns uses the fetcher to get the contributions" do
    github = Github.new(username: "pcarranza", fetcher: fetcher)
    expect(github.contributions).to eq(GithubContributions.new(contributions: contributions))

  end

  it "fails without a username or fetcher" do
    expect { Github.new }.to raise_error(KeyError)
  end
end

describe ContributionsFetcher do
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

describe GithubContributions do

  it "picks the maximun contribution from all" do
    contributions = GithubContributions.new(contributions: [
                                      Contribution.new(0, "2014-06-11"),
                                      Contribution.new(7, "2014-06-12"),
                                      Contribution.new(0, "2014-06-13"),
                                      Contribution.new(4, "2014-06-14")])
    expect(contributions.max).to eq Contribution.new(7, "2014-06-12")
  end

  it "calculates the baseline as 10 when the max contribution is 0" do
    contributions = GithubContributions.new(contributions: [Contribution.new(0, "2014-06-11")])
    expect(contributions.baseline_commits).to eq(10)
  end
  it "calculates the baseline as 10 when the max contribution is 1" do
    contributions = GithubContributions.new(contributions: [Contribution.new(1, "2014-06-11")])
    expect(contributions.baseline_commits).to eq(10)
  end
  it "calculates the baseline as 30 when the max contribution is 12" do
    contributions = GithubContributions.new(contributions: [Contribution.new(12, "2014-06-11")])
    expect(contributions.baseline_commits).to eq(30)
  end

  context "with some fixed contributions" do
    let(:contributions) do
      GithubContributions.new(contributions: [
                        Contribution.new(0, "2014-06-11"),
                        Contribution.new(7, "2014-06-12"),
                        Contribution.new(0, "2014-06-13"),
                        Contribution.new(4, "2014-06-14"),
                        Contribution.new(3, "2014-06-15"),
                        Contribution.new(2, "2014-06-16"),
                        Contribution.new(1, "2014-06-17"),
                        Contribution.new(0, "2014-06-18"),
                        Contribution.new(3, "2014-06-19"),
                        Contribution.new(2, "2014-06-20"),
                        Contribution.new(1, "2014-06-21"),
                        Contribution.new(0, "2014-06-22")
      ])
    end
    it "finds the first full week" do
      expect(contributions.first_commitable_date).to eq(Date.parse("2014-06-15"))
    end
    it "finds the first full week with contributions starting in sunday" do
      expect(GithubContributions.new(contributions: [Contribution.new(0, "2014-07-13")]).first_commitable_date).
        to eq(Date.parse("2014-07-13"))
    end
    it "finds a given contribution by date" do
      expect(contributions.find_by_date(Date.parse("2014-06-15"))).to eq(
        Contribution.new(3, "2014-06-15"))
      expect(contributions.find_by_date(Date.parse("2014-06-19"))).to eq(
        Contribution.new(3, "2014-06-19"))
    end

    it "can be enumerated" do
      count = 0
      contributions.each do |contribution|
        count += 1
      end
      expect(count).to eq(12)
    end
  end
end
