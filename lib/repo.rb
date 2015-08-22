require "pathname"

class Repo

  attr_reader :name, :path

  def initialize(**options)
    @name = options.fetch(:name)
    @workdir = options.fetch(:workdir) { Dir.pwd }
    @path = Pathname.new(@workdir).join(@name).to_s
  end

  def run(command, path: @path)
    Dir.chdir(path) do
      %x[#{command.to_s}]
    end
  end

  def create
    run("git init #{@name}", path: @workdir) unless File.exists?(@path)
    self
  end

  def commits
    run("git rev-list HEAD --count").to_i
  end

end

class Commit
  def initialize(message: "Beep", options: "--allow-empty", **args)
    @message = message
    @options = options
    @date = args[:date]
  end

  def to_s
    "#{prefix}git commit -m '#{@message}' #{@options}"
  end

  private

  def prefix
    "GIT_AUTHOR_DATE=#{datetime} GIT_COMMITTER_DATE=#{datetime} " if @date
  end

  def datetime
    @date.strftime("%FT%T")
  end
end
