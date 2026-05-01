extends Node

@onready var shell: Shell = %Shell
@onready var camera: ShakingCamera = %Camera
@onready var timer: Timer = %Timer

@onready var walls: TileMapLayer = %Walls
@onready var snake: TileMapLayer = %Snake
@onready var food: TileMapLayer = %Food

@onready var audio_eat: AudioStreamPlayer = %AudioEat
@onready var audio_boost: AudioStreamPlayer = %AudioBoost
@onready var audio_shrink: AudioStreamPlayer = %AudioShrink
@onready var audio_death: AudioStreamPlayer = %AudioDeath

@onready var smoke_boost: OneShotParticles = %SmokeBoost
@onready var smoke_death: GPUParticles2D = %SmokeDeath

const SPEED := 10
const SNAKE_SIZE := 3
const BOOSTER := 10
const FOOD_FREQUENCY := 30
const FOOD_MAX := 5

var segments: Array[Vector2i] = []
var snake_variant := Vector2i.ZERO
var food_ticker := 0
var eating := false
var god_mode := false

var queue: Dictionary[String, int] = {
  add = 0,
  remove = 0,
  boost = 0,
}

var directions: Dictionary[String, Vector2i] = {
  current = Vector2i.ZERO,
  next = Vector2i.ZERO,
}

const scores: Dictionary[String, int] = {
  red = 10,
  green = 50,
  yellow = 100,
}

const FOOD_TILES := {
  red = Vector2i(0, 21),
  green = Vector2i(1, 21),
  yellow = Vector2i(2, 21),
}

var default_food := FOOD_TILES.red

const SNAKE_TILES := {
  head = {
    Vector2i.UP: Vector2i(1, 3),
    Vector2i.LEFT: Vector2i(1, 4),
    Vector2i.DOWN: Vector2i(1, 5),
    Vector2i.RIGHT: Vector2i(1, 6),
  },

  head_eating = {
    Vector2i.UP: Vector2i(0, 3),
    Vector2i.LEFT: Vector2i(0, 4),
    Vector2i.DOWN: Vector2i(0, 5),
    Vector2i.RIGHT: Vector2i(0, 6),
  },

  head_dead = {
    Vector2i.UP: Vector2i(8, 3),
    Vector2i.LEFT: Vector2i(8, 4),
    Vector2i.DOWN: Vector2i(8, 5),
    Vector2i.RIGHT: Vector2i(8, 6),
  },

  body = {
    Vector2i.UP: Vector2i(0, 2),
    Vector2i.DOWN: Vector2i(0, 2),
    Vector2i.LEFT: Vector2i(1, 2),
    Vector2i.RIGHT: Vector2i(1, 2),
  },

  corners = {
    [Vector2i.RIGHT, Vector2i.UP]: Vector2i(2, 2),
    [Vector2i.DOWN, Vector2i.LEFT]: Vector2i(2, 2),
    [Vector2i.LEFT, Vector2i.UP]: Vector2i(3, 2),
    [Vector2i.DOWN, Vector2i.RIGHT]: Vector2i(3, 2),
    [Vector2i.RIGHT, Vector2i.DOWN]: Vector2i(4, 2),
    [Vector2i.UP, Vector2i.LEFT]: Vector2i(4, 2),
    [Vector2i.LEFT, Vector2i.DOWN]: Vector2i(5, 2),
    [Vector2i.UP, Vector2i.RIGHT]: Vector2i(5, 2),
  },

  tail = {
    Vector2i.UP: Vector2i(6, 2),
    Vector2i.DOWN: Vector2i(8, 2),
    Vector2i.LEFT: Vector2i(7, 2),
    Vector2i.RIGHT: Vector2i(9, 2),
  },
}

func _ready() -> void:
  start_game()

func _on_timer_timeout() -> void:
  move_snake()
  add_food()

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed('debug-god-mode'):
    god_mode = !god_mode
    shell.log('God mode ' + ('Enabled' if god_mode else 'Disabled'))
    return
  elif event.is_action_pressed('debug-1'):
    default_food = FOOD_TILES.red
    shell.log('preferring Red food')
    return
  elif event.is_action_pressed('debug-2'):
    default_food = FOOD_TILES.green
    shell.log('preferring Green food')
    return
  elif event.is_action_pressed('debug-3'):
    default_food = FOOD_TILES.yellow
    shell.log('preferring Yellow food')
    return
  elif shell.is_game_over:
    return

  if event.is_action_pressed('up') and directions.current != Vector2i.DOWN:
    directions.next = Vector2i.UP
  elif event.is_action_pressed('down') and directions.current != Vector2i.UP:
    directions.next = Vector2i.DOWN
  elif event.is_action_pressed('left') and directions.current != Vector2i.RIGHT:
    directions.next = Vector2i.LEFT
  elif event.is_action_pressed('right') and directions.current != Vector2i.LEFT:
    directions.next = Vector2i.RIGHT
  else:
    return

  if timer.is_stopped():
    timer.start()
    move_snake()

func set_speed(speed: int) -> void:
  timer.wait_time = 1.0 / speed

func start_game() -> void:
  shell.reset()

  directions.current = Vector2i.RIGHT
  set_speed(SPEED)

  snake.clear()
  food.clear()
  segments.clear()
  queue.add = 0
  queue.remove = 0
  queue.boost = 0

  snake_variant = Vector2i(0, 7 * (randi() % 3))
  eating = false

  (snake.material as ShaderMaterial).set_shader_parameter('intensity', 0)

  var rect := walls.get_used_rect()
  var start := Vector2i(int(rect.size.x * 0.3), int(rect.size.y * 0.5))
  for i in range(SNAKE_SIZE):
    segments.append(start - i * directions.current)

  render_snake()

func end_game() -> void:
  timer.stop()
  if god_mode:
    return

  audio_death.play()
  spawn_particles(smoke_death, Util.get_tile_position(food, segments[0]) + directions.current * Vector2i(food.tile_set.tile_size * 0.4))
  camera.apply_shake(1.0)

  shell.game_over()
  render_snake()

func render_snake() -> void:
  snake.clear()

  var tile: Vector2i
  var source: int
  var last_segment: Vector2i
  var last_direction: Vector2i

  var intensity := minf(0.8, 0.1 + pow(segments.size(), 2.3) / 100_000)
  (snake.material as ShaderMaterial).set_shader_parameter('intensity', intensity)

  for index in range(segments.size()):
    var segment := segments[index]
    if last_segment:
      source = 1
      var direction := last_segment - segment
      if index == segments.size() - 1:
        tile = SNAKE_TILES.tail.get(direction, Vector2i.ZERO)
      else:
        tile = SNAKE_TILES.body.get(direction, Vector2i.ZERO)

      if last_direction and direction != last_direction:
        var corner_tile: Vector2i = SNAKE_TILES.corners.get([direction, last_direction], Vector2i.ZERO)
        assert(corner_tile != Vector2i.ZERO, 'Invalid corner')
        snake.set_cell(last_segment, source, corner_tile + snake_variant)
      last_direction = direction
    elif shell.is_game_over:
      source = 3
      tile = SNAKE_TILES.head_dead[directions.current]
    elif eating:
      source = 3
      tile = SNAKE_TILES.head_eating[directions.current]
    else:
      source = 1
      tile = SNAKE_TILES.head[directions.current]

    assert(tile != Vector2i.ZERO, 'Invalid direction')
    snake.set_cell(segment, source, tile + snake_variant)
    last_segment = segment

func move_snake() -> void:
  if shell.is_game_over:
    return

  # Calculate new head position
  var head: Vector2i = segments[0] + directions.next

  # Check collisions with walls
  if walls.get_cell_source_id(head) >= 0:
    return end_game()
#
  ## Check collisions with self
  for i in range(1, len(segments)):
    if head == segments[i]:
      return end_game()

  # Check collisions with food
  if food.get_cell_source_id(head) >= 0:
    eat_food(head)

  # Move snake segments
  var tail := segments[-1]
  segments = segments.slice(0, -1)
  segments.insert(0, head)
  directions.current = directions.next

  # Add segments
  if queue.add > 0:
    segments.append(tail)
    queue.add -= 1

  # Remove segments
  if queue.remove > 0:
    segments.resize(maxi(3, segments.size() - 3))
    queue.remove = maxi(0, queue.remove - 3)
    if queue.remove == 0:
      food.set_cell(segments[-1], 1, FOOD_TILES.yellow)

  # Boost speed
  if queue.boost > 0:
    spawn_particles(smoke_boost, Util.get_tile_position(food, segments[0]))
    set_speed(SPEED * 3)
    queue.boost -= 1
    if queue.boost == 0:
      set_speed(SPEED)

  render_snake()

func add_food() -> void:
  food_ticker = maxi(0, food_ticker - 1)
  var count := food.get_used_cells().size()
  if count < FOOD_MAX and (count == 0 or food_ticker == 0):
    food_ticker = FOOD_FREQUENCY
  else:
    return

  var tile := default_food
  var length := segments.size()

  if length > BOOSTER / 2.0 and randi() % 5 == 0 and food.get_used_cells_by_id(1, FOOD_TILES.yellow).size() == 0:
    tile = FOOD_TILES.yellow
  elif length > BOOSTER * 2 and randi() % 5 == 0 and food.get_used_cells_by_id(1, FOOD_TILES.green).size() == 0:
    tile = FOOD_TILES.green

  var rect := walls.get_used_rect()

  while true:
    var pos := Vector2i(
      randi() % (rect.size.x - 2) + 1,
      randi() % (rect.size.y - 2) + 1
    )

    if (snake.get_cell_source_id(pos) < 0 and food.get_cell_source_id(pos) < 0):
      food.set_cell(pos, 1, tile)
      return

func eat_food(pos: Vector2i) -> void:
  audio_eat.play()

  eating = true
  var sprite := Util.get_tile_sprite(food, pos)
  sprite.modulate.a = 0.75
  sprite.position = Util.get_tile_position(food, pos)
  add_child(sprite)
  Util.grow_and_fade(sprite)
  get_tree().create_timer(0.5).timeout.connect(
    func() -> void: eating = false
  )

  var tile := food.get_cell_atlas_coords(pos)
  food.erase_cell(pos)

  if tile == FOOD_TILES.red:
    shell.add_score(scores.red)
    queue.add += 1
  elif tile == FOOD_TILES.green:
    audio_shrink.play()
    shell.add_score(scores.green)
    queue.remove += BOOSTER
  elif tile == FOOD_TILES.yellow:
    audio_boost.play()
    camera.apply_shake(0.8)
    shell.add_score(scores.yellow)
    queue.add += BOOSTER
    queue.boost += BOOSTER

func spawn_particles(source: GPUParticles2D, pos: Vector2i) -> void:
  var particles: GPUParticles2D = source.duplicate()
  particles.visible = true
  particles.global_position = pos
  particles.rotation = Vector2(directions.current).angle()
  add_child(particles)
