require "ruby-git"

class Repo

  attr_reader :name, :path

  def initialize(**options)
    @name = options.fetch(:name)
    @workdir = options.fetch(:workdir) { Dir.pwd }
    @path = Pathname.new(@workdir).join(@name).to_s
  end

  def create
    Dir.chdir(@workdir) do
      %x[git init #{@name}]
    end
    self
  end

  def commit(message: "Beep", options: "--allow-empty", prefix: "")
    execute("#{prefix} git commit -m '#{message}' #{options}")
    self
  end

  def commits
    execute("git rev-list HEAD --count").to_i
  end

  private

  def execute(command)
    Dir.chdir(@path) do
      %x[#{command}]
    end
  end
end
