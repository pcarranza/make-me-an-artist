require "spec_helper"
require "tmpdir"

describe Commit do
  it "uses default values when built without args" do
    expect(Commit.new.to_s).to eq("git commit -m 'Beep' --allow-empty")
  end

  it "uses the message provided" do
    expect(Commit.new(message: "testing").to_s).to eq("git commit -m 'testing' --allow-empty")
  end

  it "uses the provided options" do
    expect(Commit.new(options: "--allow-empty-message").to_s).to eq("git commit -m 'Beep' --allow-empty-message")
  end

  it "takes a date and adds it as environment value" do
    expect(Commit.new(date: DateTime.parse("2015-01-01")).to_s).
      to eq("GIT_AUTHOR_DATE=2015-01-01T00:00:00 GIT_COMMITTER_DATE=2015-01-01T00:00:00 git commit -m 'Beep' --allow-empty")
  end

  it "takes a date and hour and adds it as environment value" do
    expect(Commit.new(date: DateTime.parse("2015-01-02T10:00:01")).to_s).
      to eq("GIT_AUTHOR_DATE=2015-01-02T10:00:01 GIT_COMMITTER_DATE=2015-01-02T10:00:01 git commit -m 'Beep' --allow-empty")
  end
end

describe Repo do
  it "requires a repo name" do
    expect{Repo.new}.to raise_error(/name/)
  end

  context "given a directory" do
    let(:workdir) { Dir.mktmpdir }
    it "can create a new repo" do
      repo = Repo.new(name: "test", workdir: workdir)
      repo.create
      expect(Dir.exists?(repo.path)).to be_truthy
    end
    it "supports creating the repo if it already exists" do
      repo = Repo.new(name: "test2", workdir: workdir)
      repo.create
      repo.create
      expect(Dir.exists?(repo.path)).to be_truthy
    end

    context "given a repo" do
      let(:repo) do
        Repo.new(name: "test", workdir: workdir)
      end

      it "can commit into that repo" do
        my_repo = repo.create
        my_repo.run(Commit.new)
        expect(my_repo.commits).to eq(1)
      end
    end

  end
end
