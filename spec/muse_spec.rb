require "spec_helper"

describe Muse do
  it "can build an artist plan for a given username" do
    artist = Muse.new(username: "pcarranza", design: Factories.commit_plan)
    expect(artist).to_not be_nil
  end
end
