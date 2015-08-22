require "spec_helper"

describe Artist do
  it "can build an artist plan for a given username" do
    artist = Artist.new(username: "pcarranza", design: Factories.commit_plan)
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
