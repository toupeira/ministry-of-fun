extends Node

@onready var shell: Shell = %Shell
@onready var ball: RigidBody2D = %Ball
@onready var paddle_left: StaticBody2D = %PaddleLeft
@onready var paddle_right: StaticBody2D = %PaddleRight
@onready var goal_left: StaticBody2D = %GoalLeft
@onready var goal_right: StaticBody2D = %GoalRight

const CENTER := Vector2i(360, 192)
const PADDLE_HEIGHT := 64
const Y_MIN := 24 + int(PADDLE_HEIGHT * 0.5)
const Y_MAX := 360 - int(PADDLE_HEIGHT * 0.5)

enum State {
  PLAY,
  SERVE_LEFT,
  SERVE_RIGHT,
}

var state: State = State.SERVE_LEFT

func _ready() -> void:
  pass

func _physics_process(_delta: float) -> void:
  match state:
    State.PLAY:
      paddle_right.global_position.y = clampf(ball.global_position.y, Y_MIN, Y_MAX)
    State.SERVE_LEFT:
      ball.sleeping = true
      ball.global_position.x = paddle_left.global_position.x + 20
      ball.global_position.y = paddle_left.global_position.y
    State.SERVE_RIGHT:
      ball.sleeping = true
      ball.global_position.x = paddle_right.global_position.x - 20
      ball.global_position.y = paddle_right.global_position.y

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    var motion := event as InputEventMouseMotion
    move_paddle(motion.global_position.y)
  elif event.is_action_pressed('up', true):
    move_paddle(paddle_left.global_position.y - 8)
  elif event.is_action_pressed('down', true):
    move_paddle(paddle_left.global_position.y + 8)
  elif event.is_action_pressed('primary') and state != State.PLAY:
    var direction := Vector2.RIGHT if state == State.SERVE_LEFT else Vector2.LEFT
    ball.apply_central_impulse(Vector2.UP * 250 + direction * 250)
    state = State.PLAY

func _on_ball_collision(body: Node) -> void:
  print('_on_ball_collision: ', body)
  match body:
    goal_left:
      state = State.SERVE_RIGHT
    goal_right:
      state = State.SERVE_LEFT

func move_paddle(y: float) -> void:
  paddle_left.global_position.y = clampf(y, Y_MIN, Y_MAX)
