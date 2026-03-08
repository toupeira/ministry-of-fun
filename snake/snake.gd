extends Node2D

@onready var timer: Timer = %Timer
@onready var hud: Hud = %Hud

@onready var walls: TileMapLayer = %Walls
@onready var snake: TileMapLayer = %Snake
@onready var food: TileMapLayer = %Food

const SPEED := 10
const SNAKE_SIZE := 3
const FOOD_FREQUENCY := 30
const FOOD_SWALLOW := 10
const FOOD_MAX := 10

var cycles := 0
var pos_start := Vector2i(12, 9)
var pos_current: Array[Vector2i] = []
var pos_old: Array[Vector2i] = []
var headOffset := Vector2i.ZERO

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

const SNAKE_TILES := {
  head = {
    Vector2i.UP: Vector2i(1, 10),
    Vector2i.LEFT: Vector2i(1, 11),
    Vector2i.DOWN: Vector2i(1, 12),
    Vector2i.RIGHT: Vector2i(1, 13),
  },

  body = {
    Vector2i.UP: Vector2i(0, 9),
    Vector2i.DOWN: Vector2i(0, 9),
    Vector2i.LEFT: Vector2i(1, 9),
    Vector2i.RIGHT: Vector2i(1, 9),
  },

  corners = {
    [Vector2i.RIGHT, Vector2i.UP]: Vector2i(2, 9),
    [Vector2i.DOWN, Vector2i.LEFT]: Vector2i(2, 9),
    [Vector2i.LEFT, Vector2i.UP]: Vector2i(3, 9),
    [Vector2i.DOWN, Vector2i.RIGHT]: Vector2i(3, 9),
    [Vector2i.RIGHT, Vector2i.DOWN]: Vector2i(4, 9),
    [Vector2i.UP, Vector2i.LEFT]: Vector2i(4, 9),
    [Vector2i.LEFT, Vector2i.DOWN]: Vector2i(5, 9),
    [Vector2i.UP, Vector2i.RIGHT]: Vector2i(5, 9),
  },

  tail = {
    Vector2i.UP: Vector2i(6, 9),
    Vector2i.DOWN: Vector2i(8, 9),
    Vector2i.LEFT: Vector2i(7, 9),
    Vector2i.RIGHT: Vector2i(9, 9),
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
  if hud.is_game_over():
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
  pos_current.clear()
  pos_old.clear()

  for i in range(SNAKE_SIZE):
    add_segment(pos_start - Vector2i(i, 0))

  render_snake()

func end_game() -> void:
  timer.stop()
  hud.game_over()

func add_segment(pos: Vector2i) -> void:
  pos_current.append(pos)

func render_snake() -> void:
  snake.clear()

  var tile: Vector2i = SNAKE_TILES.head[directions.current] + headOffset
  var lastSegment: Vector2i
  var lastDirection: Vector2i

  for index in range(pos_current.size()):
    var segment := pos_current[index]
    if lastSegment:
      var direction := lastSegment - segment
      if index == pos_current.size() - 1:
        tile= SNAKE_TILES.tail[direction]
      else:
        tile = SNAKE_TILES.body[direction]

      if lastDirection and direction != lastDirection:
        var cornerTile: Vector2i = SNAKE_TILES.corners[[direction, lastDirection]]
        snake.set_cell(lastSegment, 1, cornerTile)
      lastDirection = direction

    snake.set_cell(segment, 1, tile)
    lastSegment = segment

func move_snake() -> void:
  if hud.is_game_over():
    return

  # Calculate new head position
  var head: Vector2i = pos_current[0] + directions.next

  # Check collisions with walls
  if walls.get_cell_source_id(head) >= 0:
    return end_game()
#
  ## Check collisions with self
  for i in range(1, len(pos_current)):
    if head == pos_current[i]:
      return end_game()

  # Check collisions with food
  if food.get_cell_source_id(head) >= 0:
    eat_food(head)

  # Move snake segments
  pos_old = pos_current.duplicate()
  pos_current[0] = head
  directions.current = directions.next

  for i in range(1, len(pos_current)):
    pos_current[i] = pos_old[i - 1]

  render_snake()

func add_food() -> void:
  var count := food.get_used_cells().size()
  if count > FOOD_MAX or not (count == 0 or cycles % FOOD_FREQUENCY == 1):
    return

  var rect := walls.get_used_rect()
  while true:
    var pos := Vector2i(randi() % rect.size.x, randi() % rect.size.y)
    if walls.get_cell_source_id(pos) < 0 and snake.get_cell_source_id(pos) < 0:
      var tile := FOOD_TILES.red
      if pos_current.size() > FOOD_SWALLOW * 2 and randi() % 10 == 0 and food.get_used_cells_by_id(1, FOOD_TILES.green).size() == 0:
        tile = FOOD_TILES.green
      food.set_cell(pos, 1, tile)
      return

func eat_food(pos: Vector2i) -> void:
  headOffset = Vector2i(3, 0)
  var sprite := Sprite2D.new()
  sprite.modulate.a = 0.4
  sprite.texture = Util.get_tile_image(food, pos)
  sprite.position = Util.get_tile_position(food, pos)
  add_child(sprite)
  Util.grow_and_fade(sprite).tween_callback(func() -> void: headOffset = Vector2i.ZERO)

  var tile = food.get_cell_atlas_coords(pos)
  food.erase_cell(pos)

  if tile == FOOD_TILES.red:
    hud.add_score(scores.red)
    add_segment(pos)
  elif tile == FOOD_TILES.green:
    hud.add_score(scores.green)
    pos_current.resize(max(3, pos_current.size() - FOOD_SWALLOW))
    food.set_cell(pos_current[-1], 1, FOOD_TILES.yellow)
  elif tile == FOOD_TILES.yellow:
    hud.add_score(scores.yellow)
    for i in range(FOOD_SWALLOW):
      _on_timer_timeout.call_deferred()
      add_segment.call_deferred(pos)
