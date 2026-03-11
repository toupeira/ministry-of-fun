extends Node2D

@onready var Smoke: PackedScene = preload('res://snake/smoke.tscn')

@onready var timer: Timer = %Timer
@onready var hud: Hud = %Hud

@onready var walls: TileMapLayer = %Walls
@onready var snake: TileMapLayer = %Snake
@onready var food: TileMapLayer = %Food

const SPEED := 10
const SNAKE_SIZE := 3
const FOOD_FREQUENCY := 30
const FOOD_BOOSTER := 12
const FOOD_MAX := 10

var cycles := 0
var pos_start := Vector2i(12, 9)
var segments: Array[Vector2i] = []
var add_segments := 0
var snake_variant := Vector2i.ZERO
var head_variant := Vector2i.ZERO
var god_mode := false

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
  hud.set_title('Snake')
  timer.wait_time = 1.0 / SPEED
  start_game()

func _on_timer_timeout() -> void:
  cycles += 1
  move_snake()
  add_food()

func _input(event: InputEvent) -> void:
  if event.is_action_pressed('debug-god-mode'):
    god_mode = !god_mode
    hud.log_debug('God mode ' + ('Enabled' if god_mode else 'Disabled'))
    return
  elif event.is_action_pressed('debug-1'):
    default_food = FOOD_TILES.red
    hud.log_debug('preferring Red food')
    return
  elif event.is_action_pressed('debug-2'):
    default_food = FOOD_TILES.green
    hud.log_debug('preferring Green food')
    return
  elif event.is_action_pressed('debug-3'):
    default_food = FOOD_TILES.yellow
    hud.log_debug('preferring Yellow food')
    return
  elif hud.is_game_over():
    if event.is_action_pressed('start'):
      start_game()
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

func start_game() -> void:
  hud.set_score(0)
  hud.reset()

  directions.current = Vector2i.RIGHT

  snake.clear()
  food.clear()
  segments.clear()
  add_segments = 0

  snake_variant = Vector2i(0, 7 * (randi() % 3))
  head_variant = Vector2i.ZERO

  (snake.material as ShaderMaterial).set_shader_parameter('intensity', 0)

  for i in range(SNAKE_SIZE):
    segments.append(pos_start - i * directions.current)

  render_snake()

func end_game() -> void:
  timer.stop()
  if not god_mode:
    hud.game_over()

func render_snake() -> void:
  snake.clear()

  var tile: Vector2i = SNAKE_TILES.head[directions.current] + head_variant
  var lastSegment: Vector2i
  var lastDirection: Vector2i

  var intensity := minf(0.8, 0.1 + pow(segments.size(), 2.3) / 100_000)
  (snake.material as ShaderMaterial).set_shader_parameter('intensity', intensity)

  for index in range(segments.size()):
    var segment := segments[index]
    if lastSegment:
      var direction := lastSegment - segment
      if index == segments.size() - 1:
        tile = SNAKE_TILES.tail.get(direction, Vector2i.ZERO)
      else:
        tile = SNAKE_TILES.body.get(direction, Vector2i.ZERO)

      if lastDirection and direction != lastDirection:
        var corner_tile: Vector2i = SNAKE_TILES.corners.get([direction, lastDirection], Vector2i.ZERO)
        if corner_tile != Vector2i.ZERO:
          snake.set_cell(lastSegment, 1, corner_tile + snake_variant)
        else:
          print("Invalid corner:")
          print(segment, lastSegment, direction, lastDirection)
      lastDirection = direction

    if tile != Vector2i.ZERO:
      snake.set_cell(segment, 1, tile + snake_variant)
    else:
      print("Invalid direction:")
      print(segment, lastSegment, lastDirection)

    lastSegment = segment

func move_snake() -> void:
  if hud.is_game_over():
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
  var tail = segments[-1]
  segments = segments.slice(0, -1)
  segments.insert(0, head)
  directions.current = directions.next

  if add_segments > 0:
    segments.append(tail)
    add_segments -= 1

  render_snake()

func add_food() -> void:
  var count := food.get_used_cells().size()
  if count > FOOD_MAX or not (count == 0 or cycles % FOOD_FREQUENCY == 1):
    return

  var rect := walls.get_used_rect()
  while true:
    var pos := Vector2i(randi() % rect.size.x, randi() % rect.size.y)

    if walls.get_cell_source_id(pos) < 0 and snake.get_cell_source_id(pos) < 0 and food.get_cell_source_id(pos) < 0:
      var tile := default_food
      if randi() % 5 == 0 and food.get_used_cells().size() > 0:
        tile = FOOD_TILES.yellow
      elif segments.size() > FOOD_BOOSTER * 2 and randi() % 5 == 0 and food.get_used_cells_by_id(1, FOOD_TILES.green).size() == 0:
        tile = FOOD_TILES.green
      food.set_cell(pos, 1, tile)
      return

func eat_food(pos: Vector2i) -> void:
  head_variant = Vector2i(3, 0)
  var sprite := Sprite2D.new()
  sprite.modulate.a = 0.4
  sprite.texture = Util.get_tile_image(food, pos)
  sprite.position = Util.get_tile_position(food, pos)
  add_child(sprite)
  Util.grow_and_fade(sprite).tween_callback(func() -> void: head_variant = Vector2i.ZERO)

  var tile := food.get_cell_atlas_coords(pos)
  food.erase_cell(pos)

  if tile == FOOD_TILES.red:
    hud.add_score(scores.red)
    add_segments += 1
  elif tile == FOOD_TILES.green:
    hud.add_score(scores.green)
    for i in range(FOOD_BOOSTER):
      await sleep(1.0 / SPEED / 4)
      segments.resize(maxi(3, segments.size() - 1))
      render_snake()
    food.set_cell(segments[-1], 1, FOOD_TILES.yellow)
  elif tile == FOOD_TILES.yellow:
    hud.add_score(scores.yellow)
    for i in range(FOOD_BOOSTER / 1.5):
      await sleep(1.0 / SPEED / 1.5)
      _on_timer_timeout()
      add_segments += 1
      spawn_particles(
        Smoke,
        Util.get_tile_position(food, segments[0]),
        directions.current
      )

func sleep(seconds: float) -> Signal:
  return get_tree().create_timer(seconds).timeout

func spawn_particles(particles_class: PackedScene, pos: Vector2i, direction: Vector2i) -> void:
  var particles: GPUParticles2D = particles_class.instantiate()
  particles.global_position = pos
  particles.one_shot = true
  if direction:
    particles.rotation = Vector2(direction).angle()
  add_child(particles)
