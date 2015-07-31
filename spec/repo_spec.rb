require "spec_helper"
require "tmpdir"

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

    context "given a repo" do
      let(:repo) do
        Repo.new(name: "test", workdir: workdir)
      end

      it "can commit into that repo" do
        my_repo = repo.create
        my_repo.commit
        expect(my_repo.commits).to eq(1)
      end

      it "can commit into that repo with a prefix" do
        my_repo = repo.create
        my_repo.commit(prefix: "GIT_AUTHOR_DATE=2015-01-01T12:00:00 GIT_COMMITTER_DATE=2015-01-01T12:00:00")
        expect(my_repo.commits).to eq(1)
      end
    end

  end
end
