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

  it "Picks the right range pair" do
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

  it "finds that 21 commits are needed to bump to mid from 0" do
    ranges = CommitRanges.new(contributions: contributions)
    expect(ranges.from(0).bump_to(:high)).to eq(21)
  end

  it "finds that 31 commits are needed to bump to mid from 0" do
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
end
