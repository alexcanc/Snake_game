require 'gosu'
require_relative 'snake'

class Food
  attr_reader :x, :y, :size

  def initialize(snake_size)
    @size = snake_size
    @x = rand((640 / snake_size).to_i) * snake_size
    @y = rand((480 / snake_size).to_i) * snake_size
  end

  def draw
    Gosu.draw_rect(@x, @y, @size, @size, Gosu::Color::RED)
  end
end

class GameWindow < Gosu::Window
  STATE_MENU = 0
  STATE_PLAY = 1

  def initialize
    snake_size = 20
    width = snake_size * 40
    height = snake_size * 30
    super(width, height)
    self.caption = 'Snake Game'

    @state = STATE_MENU
    @play_button_scale = 0.1
    @play_button_x = width / 2
    @play_button_y = height / 2

    @snake = Snake.new(width, height, snake_size)
    @food = Food.new(snake_size)
    @snake_speed = 0.1
    @last_move_time = Time.now
    @score = 0

    @font = Gosu::Font.new(20)
    @start_sound = Gosu::Sample.new(File.join(__dir__, 'start.wav'))
    @eat_sound = Gosu::Sample.new(File.join(__dir__, 'eat.wav'))

    @game_start_sound = Gosu::Sample.new(File.join(__dir__, 'start.wav'))
    check_sound_load(@start_sound)
    check_sound_load(@eat_sound)
    check_sound_load(@game_start_sound)

    @play_button_image = Gosu::Image.new(File.join(__dir__, 'play.png'))
    @play_button_width = @play_button_image.width * @play_button_scale
    @play_button_height = @play_button_image.height * @play_button_scale
  end

  def draw
    if @state == STATE_MENU
      draw_menu
    elsif @state == STATE_PLAY
      draw_game
    end
  end

  def update
    if @state == STATE_PLAY
      if (Time.now - @last_move_time) >= @snake_speed
        @snake.move
        @last_move_time = Time.now

        if snake_hit_food?
          @score += 1
          @eat_sound.play if @eat_sound
          @snake.grow
          regenerate_food
          increase_speed
        end
      end
    end
  end

  def button_down(id)
    if @state == STATE_MENU
      if id == Gosu::MS_LEFT && mouse_over_play_button?
        start_game
      end
    elsif @state == STATE_PLAY
      case id
      when Gosu::KB_UP
        @snake.change_direction(:up)
      when Gosu::KB_DOWN
        @snake.change_direction(:down)
      when Gosu::KB_LEFT
        @snake.change_direction(:left)
      when Gosu::KB_RIGHT
        @snake.change_direction(:right)
      end
    end
  end

  private

  def draw_menu
    welcome_message = 'Welcome to the Snake Game!'
    welcome_x = width / 2 - @font.text_width(welcome_message)
    welcome_y = @play_button_y - @play_button_height / 2

    @font.draw(welcome_message, welcome_x, welcome_y, 0, 2, 2)
    draw_button(@play_button_image, @play_button_x, @play_button_y, @play_button_scale)
  end

  def draw_button(image, x, y, scale)
    image.draw(x - image.width * scale / 2, y - image.height * scale / 2, 1, scale, scale)
  end

  def draw_game
    @snake.draw
    @food.draw
    @font.draw("Score: #{@score}", 10, 10, 0)
    @font.draw("Speed: #{@snake_speed}", 10, 40, 0)
  end

  def mouse_over_play_button?
    mouse_x > @play_button_x - @play_button_width / 2 &&
      mouse_x < @play_button_x + @play_button_width / 2 &&
      mouse_y > @play_button_y - @play_button_height / 2 &&
      mouse_y < @play_button_y + @play_button_height / 2
  end

  def start_game
    @state = STATE_PLAY
    @game_start_sound.play if @game_start_sound
  end

  def snake_hit_food?
    @snake.x == @food.x && @snake.y == @food.y
  end

  def regenerate_food
    @food = Food.new(@snake.size)
  end

  def increase_speed
    @snake_speed -= 0.01
  end

  def check_sound_load(sound)
    if sound.nil?
      puts "Failed to load sound file: #{sound&.filename}"
    end
  end
end

window = GameWindow.new
window.show
