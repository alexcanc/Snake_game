require 'gosu'

class Snake
  SIZE = 20

  def initialize(window_width, window_height, snake_size)
    @window_width = window_width
    @window_height = window_height
    @x = 0
    @y = 0
    @size = snake_size || SIZE
    @direction = :right
    @body = []
  end

  def draw
    Gosu.draw_rect(@x, @y, @size, @size, Gosu::Color::WHITE)
    @body.each do |segment|
      Gosu.draw_rect(segment[:x], segment[:y], @size, @size, Gosu::Color::WHITE)
    end
  end

  def move
    @body.unshift({ x: @x, y: @y })  # Add current position to the body

    case @direction
    when :up
      @y -= @size
    when :down
      @y += @size
    when :left
      @x -= @size
    when :right
      @x += @size
    end

    wrap_around_screen  # Wrap around the screen if out of bounds

    if @body.length > 1
      @body.pop
    end
  end

  def change_direction(direction)
    case direction
    when :up
      @direction = direction unless @direction == :down
    when :down
      @direction = direction unless @direction == :up
    when :left
      @direction = direction unless @direction == :right
    when :right
      @direction = direction unless @direction == :left
    end
  end

  def grow
    @body << { x: @x, y: @y }
  end

  def x
    @x
  end

  def y
    @y
  end

  def size
    @size
  end

  private

  def wrap_around_screen
    if @x < 0
      @x = @window_width - @size
    elsif @x >= @window_width
      @x = 0
    end

    if @y < 0
      @y = @window_height - @size
    elsif @y >= @window_height
      @y = 0
    end
  end
end
