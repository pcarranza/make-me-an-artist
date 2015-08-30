require "spec_helper"

describe Muse do
  it "can build an artist plan for a given username" do
    artist = Muse.new(username: "pcarranza", design: Factories.commit_plan)
    expect(artist).to_not be_nil
  end
end

describe Design do
  let(:simple_design) do
    [[1], [1], [1], [1], [1], [1], [1]]
  end
  it "can add 2 designs" do
    design = Design.new.add(simple_design).add(simple_design).create
    expect(design).to eq([[1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1]])
  end
  it "can skip as many weeks as required" do
    design = Design.new(skip_weeks: 1).add(simple_design).add(simple_design).create
    expect(design).to eq(simple_design)
  end
  it "is empty if skip is more than available" do
    design = Design.new(skip_weeks: 10).add(simple_design).add(simple_design).create
    expect(design).to eq([[], [], [], [], [], [], []])
  end
end

# describe Strategy do
#   let(:simple_design) do
#     [[1], [1], [1], [1], [1], [1], [1]]
#   end
#   let(:commit_ranges) do
#     { zero: 0, low: 20, mid: 40, high: 60, max: 80 }
#   end
#   let(:contributions) do
#     GithubContributions.new(contributions: (1..10).inject([]) { |list, value|
#       list << Contribution.new(0, Date.parse("2014-06-11") + value) })
#   end
#   it "Commits given the right calculator of commits" do
#     strategy = Strategy.new(design: simple_design, contributions: contributions, commit_ranges: commit_ranges)
#   end
# end
