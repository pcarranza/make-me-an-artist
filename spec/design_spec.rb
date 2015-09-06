require "spec_helper"

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

  it "can load all the available designs" do
    design = Design.from_list(Designs.methods(false))
    expect(design).not_to be_nil
  end
end
