require "spec_helper"

describe "CommitRanges" do

  let(:contributions) do
    Contributions.new(contributions: [
      Contribution.new(0, "2014-06-01"),
      Contribution.new(9, "2014-06-02"),
      Contribution.new(4, "2014-06-03"),
      Contribution.new(1, "2014-06-04"),
      Contribution.new(0, "2014-06-05")])
  end

  it "calculates the basic case correctly" do
    ranges = CommitRanges.new(contributions: contributions)
    expect([ranges[:zero], ranges[:low], ranges[:mid], ranges[:high], ranges[:max]]).to eq(
      [0, 10, 20, 30, 40])
  end

  it "calculates the commit ranges fine with a larger ranges starting on the next tens" do
    ranges = CommitRanges.new(contributions: Contributions.new(
      contributions: [Contribution.new(23, "2014-06-01")]))
    expect(ranges.to_h).to eq(0 => 0, 1 => 30, 2 => 60, 3 => 90, 4 => 120)
  end

  it "calculates the commit ranges fine with a larger ranges also on the tens" do
    ranges = CommitRanges.new(contributions: Contributions.new(
      contributions: [Contribution.new(30, "2014-06-01")]))
    expect(ranges.to_h).to eq(0 => 0, 1 => 40, 2 => 80, 3 => 120, 4 => 160)
  end

  it "can translate numbers to range names" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.name_for(0)).to eq(:zero)
    expect(ranges.name_for(1)).to eq(:low)
    expect(ranges.name_for(2)).to eq(:mid)
    expect(ranges.name_for(3)).to eq(:high)
    expect(ranges.name_for(4)).to eq(:max)
  end

  it "picks the right range pair" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.range_pair(:low)).to eq(RangePair.new(:zero, :low))
    expect(ranges.range_pair(:mid)).to eq(RangePair.new(:low, :mid))
    expect(ranges.range_pair(:high)).to eq(RangePair.new(:mid, :high))
    expect(ranges.range_pair(:max)).to eq(RangePair.new(:high, :max))
  end

  it "finds that 1 commit is needed to bump to low from 0" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:low)).to eq(1)
  end

  it "finds that 11 commits are needed to bump to mid from 0" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:mid)).to eq(11)
  end

  it "finds that 21 commits are needed to bump to high from 0" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:high)).to eq(21)
  end

  it "finds that 31 commits are needed to bump to max from 0" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:max)).to eq(31)
  end

  it "finds that no commit is needed to bump to low from 1" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(1).bump_to(:low)).to eq(0)
  end

  it "finds that 10 commits are needed to bump to mid from 1" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(1).bump_to(:mid)).to eq(10)
  end

  it "finds that no commits are needed to bump to max from max" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(31).bump_to(:max)).to eq(0)
  end

  it "finds that bumping from 1 to zero results in 0 commits" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(1).bump_to(:zero)).to eq(0)
  end

end

describe CommitPlan do

  it "Builds correctly" do
    expect(CommitPlan.new(Factories.commit_plan)).not_to be_nil
  end

  it "Fails to build with an invalid commit plan" do
    expect{CommitPlan.new([])}.to raise_error(/Invalid commit list/)
    expect{CommitPlan.new((0..4).to_a)}.to raise_error(/Invalid commit list/)
    expect{CommitPlan.new((0..5).to_a)}.to raise_error(/Invalid commit list/)
    expect{CommitPlan.new((0..7).to_a)}.to raise_error(/Invalid commit list/)
  end

  it "Picks the correct days given a week" do
    commit_plan = CommitPlan.new(Factories.commit_plan)
    expect(commit_plan.week(0)).to eq([1, 1, 1, 1, 1, 1, 1])
    expect(commit_plan.week(1)).to eq([1, 1, 1, 4, 1, 1, 3])
    expect(commit_plan.week(2)).to eq([1, 3, 4, 4, 4, 4, 3])
  end

end

describe "CommitPlanning" do

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
      CommitPlan.new(days)
    end

    let(:fifty_three_weeks_contributions) do
      contributions = []
      (0..7 * 53).each do |offset|
        contributions << Contribution.new(offset % 10, (initial_date + offset).to_s)
      end
      Contributions.new(contributions: contributions)
    end

    it "can pick the right week in the same year" do
      planning = CommitPlanning.new(plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
      expect(planning.week_for_date(initial_date)).to eq(0)
      expect(planning.week_for_date(initial_date + 1)).to eq(0)
      expect(planning.week_for_date(initial_date + 7)).to eq(1)
      expect(planning.week_for_date(initial_date + 8)).to eq(1)
      expect(planning.week_for_date(initial_date + 14)).to eq(2)
      expect(planning.week_for_date(initial_date + 21)).to eq(3)
    end

    it "can pick the right week in a different year" do
      planning = CommitPlanning.new(plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
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
      planning = CommitPlanning.new(plan: fifty_three_weeks_plan, contributions: fifty_three_weeks_contributions)
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

  end

  context "with one week plan and contributions" do

    let(:one_week_plan) do
      plan = []
      7.times do |day_of_week| plan << [1] end
      CommitPlan.new(plan)
    end

    let(:one_week_contributions) do
      contributions_list = []
      [[0, "2014-06-11"], [7, "2014-06-12"], [0, "2014-06-13"], [4, "2014-06-14"],
        [0, "2014-06-15"], [0, "2014-06-16"], [1, "2014-06-17"], [0, "2014-06-18"],
        [3, "2014-06-19"], [2, "2014-06-20"], [1, "2014-06-21"], [0, "2014-06-22"]].each do |commits, date|
        contributions_list << Contribution.new(commits, date)
        end
      Contributions.new(contributions: contributions_list)
    end

    it "finds the right week" do
      planning = CommitPlanning.new(plan: one_week_plan, contributions: one_week_contributions)
    end

    it "skips committing before the first day of week" do
      planning = CommitPlanning.new(plan: one_week_plan, contributions: one_week_contributions)
      expect(planning.commits_for_date(Date.parse("2014-06-11"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-12"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-13"))).to eq(0)
      expect(planning.commits_for_date(Date.parse("2014-06-14"))).to eq(0)
    end

    it "plans commits for the first week correctly" do
      planning = CommitPlanning.new(plan: one_week_plan, contributions: one_week_contributions)
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
