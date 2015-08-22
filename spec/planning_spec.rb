require "spec_helper"

describe CommitRangeCalculator do

  let(:contributions) do
    GithubContributions.new(contributions: [
      Contribution.new(0, "2014-06-01"),
      Contribution.new(9, "2014-06-02"),
      Contribution.new(4, "2014-06-03"),
      Contribution.new(1, "2014-06-04"),
      Contribution.new(0, "2014-06-05")])
  end

  it "calculates the basic case correctly" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect([ranges[:zero], ranges[:low], ranges[:mid], ranges[:high], ranges[:max]]).to eq(
      [0, 10, 20, 30, 40])
  end

  it "calculates the commit ranges fine with a larger ranges starting on the next tens" do
    ranges = CommitRangeCalculator.new(contributions: GithubContributions.new(
      contributions: [Contribution.new(23, "2014-06-01")]))
    expect(ranges.to_h).to eq(0 => 0, 1 => 30, 2 => 60, 3 => 90, 4 => 120)
  end

  it "calculates the commit ranges fine with a larger ranges also on the tens" do
    ranges = CommitRangeCalculator.new(contributions: GithubContributions.new(
      contributions: [Contribution.new(30, "2014-06-01")]))
    expect(ranges.to_h).to eq(0 => 0, 1 => 40, 2 => 80, 3 => 120, 4 => 160)
  end

  it "can translate numbers to range names" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.name_for(0)).to eq(:zero)
    expect(ranges.name_for(1)).to eq(:low)
    expect(ranges.name_for(2)).to eq(:mid)
    expect(ranges.name_for(3)).to eq(:high)
    expect(ranges.name_for(4)).to eq(:max)
  end

  it "picks the right range pair" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.range_pair(:low)).to eq(RangePair.new(:zero, :low))
    expect(ranges.range_pair(:mid)).to eq(RangePair.new(:low, :mid))
    expect(ranges.range_pair(:high)).to eq(RangePair.new(:mid, :high))
    expect(ranges.range_pair(:max)).to eq(RangePair.new(:high, :max))
  end

  it "finds that 1 commit is needed to bump to low from 0" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:low)).to eq(1)
  end

  it "finds that 11 commits are needed to bump to mid from 0" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:mid)).to eq(11)
  end

  it "finds that 21 commits are needed to bump to high from 0" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:high)).to eq(21)
  end

  it "finds that 31 commits are needed to bump to max from 0" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:max)).to eq(31)
  end

  it "finds that no commit is needed to bump to low from 1" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(1).bump_to(:low)).to eq(0)
  end

  it "finds that 10 commits are needed to bump to mid from 1" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(1).bump_to(:mid)).to eq(10)
  end

  it "finds that no commits are needed to bump to max from max" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(31).bump_to(:max)).to eq(0)
  end

  it "finds that bumping from 1 to zero results in 0 commits" do
    ranges = CommitRangeCalculator.new(contributions: contributions)
    expect(ranges.from(1).bump_to(:zero)).to eq(0)
  end

  it "can be forced to have a specific range" do
    ranges = CommitRangeCalculator.new(contributions: contributions,
                                       commit_ranges: { zero: 0, low: 20, mid: 40, high: 60, max: 80 })
    expect(ranges.to_h).to eq(0 => 0, 1 => 20, 2 => 40, 3 => 60, 4 => 80)
  end

end

describe DesiredContributionsGraph do

  it "Builds correctly" do
    expect(DesiredContributionsGraph.new(Factories.commit_plan)).not_to be_nil
  end

  it "Fails to build with an invalid commit plan" do
    expect{DesiredContributionsGraph.new([])}.to raise_error(/Invalid commit list/)
    expect{DesiredContributionsGraph.new((0..4).to_a)}.to raise_error(/Invalid commit list/)
    expect{DesiredContributionsGraph.new((0..5).to_a)}.to raise_error(/Invalid commit list/)
    expect{DesiredContributionsGraph.new((0..7).to_a)}.to raise_error(/Invalid commit list/)
  end

  it "Picks the correct days given a week" do
    commit_plan = DesiredContributionsGraph.new(Factories.commit_plan)
    expect(commit_plan.week(0)).to eq([1, 1, 1, 1, 1, 1, 1])
    expect(commit_plan.week(1)).to eq([1, 1, 1, 4, 1, 1, 3])
    expect(commit_plan.week(2)).to eq([1, 3, 4, 4, 4, 4, 3])
  end

end

describe "CommitsPerDateCalculator" do

  let(:initial_date) do
    Date.parse("2014-07-13")
  end

  context "with full year plan and contributions" do
    let(:fifty_three_weeks_plan) do
      days = []
      7.times do |day_of_week|
        weeks = []
        53.times do |week_of_year| weeks << week_of_year % 5 end
        days << weeks
      end
      DesiredContributionsGraph.new(days)
    end

    let(:fifty_three_weeks_contributions) do
      contributions = []
      (0..7 * 53).each do |offset|
        contributions << Contribution.new(offset % 10, (initial_date + offset).to_s)
      end
      GithubContributions.new(contributions: contributions)
    end

    it "calculates 53 weeks in the plan" do
      expect(fifty_three_weeks_plan.weeks).to eq 53
    end

    it "can pick the right week in the same year" do
      planning = CommitsPerDateCalculator.new(commit_plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
      expect(planning.week_for_date(initial_date)).to eq(0)
      expect(planning.week_for_date(initial_date + 1)).to eq(0)
      expect(planning.week_for_date(initial_date + 7)).to eq(1)
      expect(planning.week_for_date(initial_date + 8)).to eq(1)
      expect(planning.week_for_date(initial_date + 14)).to eq(2)
      expect(planning.week_for_date(initial_date + 21)).to eq(3)
    end

    it "can pick the right week in a different year" do
      planning = CommitsPerDateCalculator.new(commit_plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
      expect(planning.week_for_date(Date.parse("2014-12-28"))).to eq(24)
      expect(planning.week_for_date(Date.parse("2014-12-29"))).to eq(24)
      expect(planning.week_for_date(Date.parse("2014-12-31"))).to eq(24)
      expect(planning.week_for_date(Date.parse("2015-01-01"))).to eq(24)
      expect(planning.week_for_date(Date.parse("2015-01-02"))).to eq(24)
      expect(planning.week_for_date(Date.parse("2015-01-03"))).to eq(24)
      expect(planning.week_for_date(Date.parse("2015-01-04"))).to eq(25)
      expect(planning.week_for_date(Date.parse("2015-01-05"))).to eq(25)
    end

    it "can plan the commits correctly" do
      planning = CommitsPerDateCalculator.new(commit_plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
      expect(planning.commits_for_date(Date.parse("2014-07-13"))).to eq(1)
      expect(planning.commits_for_date(Date.parse("2014-07-14"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-15"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-16"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-17"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-18"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-19"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-20"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-21"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-22"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-23"))).to eq(1)
      expect(planning.commits_for_date(Date.parse("2014-07-24"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-07-27"))).to eq(7)
      expect(planning.commits_for_date(Date.parse("2014-07-28"))).to eq(6)
      expect(planning.commits_for_date(Date.parse("2014-07-29"))).to eq(5)
      expect(planning.commits_for_date(Date.parse("2014-07-30"))).to eq(4)
      expect(planning.commits_for_date(Date.parse("2014-08-03"))).to eq(20)
      expect(planning.commits_for_date(Date.parse("2014-08-04"))).to eq(19)
      expect(planning.commits_for_date(Date.parse("2014-08-05"))).to eq(18)
      expect(planning.commits_for_date(Date.parse("2014-08-10"))).to eq(23)
    end

    it "provides the right amount of required commits" do
      planning = CommitsPerDateCalculator.new(commit_plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
      dates = (Date.parse("2014-07-13")..Date.parse("2015-07-18")).to_a
      expected_commits = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 7, 6, 5, 4,
        3, 2, 11, 20, 19, 18, 17, 16, 15, 14, 23, 22, 31, 30, 29, 28, 27, 0, 0,
        0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 11, 10, 9, 8, 7, 6, 15, 14, 13,
        12, 21, 20, 19, 28, 27, 26, 25, 24, 23, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1, 0, 0, 0, 7, 6, 5, 4, 3, 2, 11, 20, 19, 18, 17, 16, 15, 14, 23,
        22, 31, 30, 29, 28, 27, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2,
        11, 10, 9, 8, 7, 6, 15, 14, 13, 12, 21, 20, 19, 28, 27, 26, 25, 24, 23,
        22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 7, 6, 5, 4, 3, 2, 11, 20,
        19, 18, 17, 16, 15, 14, 23, 22, 31, 30, 29, 28, 27, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 0, 2, 11, 10, 9, 8, 7, 6, 15, 14, 13, 12, 21, 20,
        19, 28, 27, 26, 25, 24, 23, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
        0, 7, 6, 5, 4, 3, 2, 11, 20, 19, 18, 17, 16, 15, 14, 23, 22, 31, 30,
        29, 28, 27, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 11, 10, 9, 8,
        7, 6, 15, 14, 13, 12, 21, 20, 19, 28, 27, 26, 25, 24, 23, 22, 1, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 7, 6, 5, 4, 3, 2, 11, 20, 19, 18, 17,
        16, 15, 14, 23, 22, 31, 30, 29, 28, 27, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0,
        0, 0, 0, 0, 2, 11, 10, 9, 8, 7, 6, 15, 14, 13, 12, 21, 20, 19, 28, 27,
        26, 25, 24, 23, 22, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 7, 6, 5,
        4, 3, 2, 11]
      planning.each_date do |date, required_commits|
        expect(date).to eq(dates.shift)
        expect(required_commits).to eq(expected_commits.shift)
      end
      expect(dates).to be_empty
      expect(expected_commits).to be_empty
    end
  end

  context "with one week plan and contributions" do

    let(:one_week_plan) do
      plan = []
      7.times do |day_of_week| plan << [1] end
      DesiredContributionsGraph.new(plan)
    end

    let(:one_week_contributions) do
      contributions_list = []
      [[0, "2014-06-11"], [7, "2014-06-12"], [0, "2014-06-13"], [4, "2014-06-14"],
        [0, "2014-06-15"], [0, "2014-06-16"], [1, "2014-06-17"], [0, "2014-06-18"],
        [3, "2014-06-19"], [2, "2014-06-20"], [1, "2014-06-21"], [0, "2014-06-22"]].each do |commits, date|
        contributions_list << Contribution.new(commits, date)
        end
      GithubContributions.new(contributions: contributions_list)
    end

    it "calculates 1 week in the plan" do
      expect(one_week_plan.weeks).to eq 1
    end

    it "finds the right week" do
      planning = CommitsPerDateCalculator.new(commit_plan: one_week_plan, contributions: one_week_contributions)
    end

    it "skips committing before the first day of week" do
      planning = CommitsPerDateCalculator.new(commit_plan: one_week_plan, contributions: one_week_contributions)
      expect(planning.commits_for_date(Date.parse("2014-06-11"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-12"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-13"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-14"))).to eq(0)
    end

    it "plans commits for the first week correctly" do
      planning = CommitsPerDateCalculator.new(commit_plan: one_week_plan, contributions: one_week_contributions)
      expect(planning.commits_for_date(Date.parse("2014-06-15"))).to eq(1)
      expect(planning.commits_for_date(Date.parse("2014-06-16"))).to eq(1)
      expect(planning.commits_for_date(Date.parse("2014-06-17"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-18"))).to eq(1)
      expect(planning.commits_for_date(Date.parse("2014-06-19"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-20"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-21"))).to eq(0)
    end

  end

end
