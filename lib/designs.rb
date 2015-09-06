class Design

  def initialize(skip_weeks: 0, weeks_offset: 0)
    @design = 7.times.inject([]) do |week|
      week << []
    end
    @skip_weeks = skip_weeks
    @weeks_offset = weeks_offset
  end

  def add(design)
    7.times do |day|
      @design[day] += design[day]
    end
    self
  end

  def create
    design = @design.clone
    @skip_weeks.times do
      7.times do |day| design[day].shift end
    end
    @weeks_offset.times do
      7.times do |day| design[day].unshift(0) end
    end
    design
  end

  def self.from_list(designs, **args)
    design = Design.new(**args)
    designs.each { |which|
      fail "There is no such design '#{which}'" unless Designs.respond_to?(which)
      design.add(Designs.send(which))
    }
    design.create
  end

end

module Designs
  def self.pingui
    [
      [1,1,1,3,3,3,3,3,1,1],
      [1,1,3,1,1,1,1,1,3,1],
      [1,1,4,1,4,1,4,1,4,1],
      [1,4,4,2,3,3,3,2,4,4],
      [1,1,4,4,2,3,2,4,4,1],
      [1,1,4,2,2,2,2,2,4,1],
      [1,3,3,1,1,1,1,1,3,3],
    ]
  end

  def self.invader
    [
      [1,1,3,1,3,3,1,3,1],
      [1,1,1,4,3,3,4,1,1],
      [1,3,3,3,3,3,3,3,3],
      [1,3,1,3,3,3,3,1,3],
      [1,2,1,3,1,1,3,1,2],
      [1,1,1,3,1,1,3,1,1],
      [1,1,2,3,1,1,3,2,1],
    ]
  end

  def self.galaga
    [
      [1,1,4,1,1,1,1,4,1],
      [1,1,1,3,1,1,3,1,1],
      [1,1,4,4,4,4,4,4,1],
      [1,4,4,4,4,4,4,4,4],
      [1,4,1,4,4,4,4,1,4],
      [1,4,1,4,1,1,4,1,4],
      [1,1,1,1,3,3,1,1,1],
    ]
  end

  def self.ghost
    [
      [1,1,2,3,3,3,2,1],
      [1,2,1,1,3,1,1,2],
      [1,3,1,4,3,1,4,3],
      [1,3,1,1,3,1,1,3],
      [1,3,3,3,3,3,3,3],
      [1,3,3,2,3,3,2,3],
      [1,3,1,1,3,1,1,3],
    ]
  end

  def self.pacman
    [
      [1,1,1,3,4,3,2,1],
      [1,1,3,4,4,4,3,2],
      [1,3,4,4,4,3,1,1],
      [1,3,4,4,1,1,1,1],
      [1,3,4,4,4,3,1,1],
      [1,1,3,4,4,4,3,2],
      [1,1,1,3,4,3,2,1],
    ]
  end

  def self.shurikens
    [
      [1,1,1,3,1,1,1,1,1,1,1,1,1],
      [1,1,1,4,3,1,1,1,1,3,1,1,1],
      [1,1,3,4,4,4,4,1,1,4,3,1,1],
      [1,3,4,4,4,3,1,1,3,4,4,4,4],
      [1,1,1,3,4,1,1,4,4,4,4,3,1],
      [1,1,1,1,3,1,1,1,1,3,4,1,1],
      [1,1,1,1,1,1,1,1,1,1,3,1,1],
    ]
  end
  def self.pill
    [
      [1,1,1,1,1,1],
      [1,1,1,1,1,1],
      [1,1,2,2,1,1],
      [1,2,3,4,3,1],
      [1,1,2,3,1,1],
      [1,1,1,1,1,1],
      [1,1,1,1,1,1]
    ]
  end
end
