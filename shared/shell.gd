class_name Shell
extends CanvasLayer

@export var game_id: String
@export var game_title: String

@onready var game_label: Label = %GameLabel
@onready var score_label: Label = %ScoreLabel
@onready var debug_label: Label = %DebugLabel

@onready var menu: Control = %Menu
@onready var menu_label: Label = %MenuLabel
@onready var button_continue: Button = %ButtonContinue
@onready var button_restart: Button = %ButtonRestart
@onready var button_quit: Button = %ButtonQuit

var score := 0
var is_game_over := false
var debug_messages: Array[String] = []

var mouse_drag := false
var mouse_start := Vector2.ZERO

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  button_quit.visible = OS.get_name() != 'Web'
  game_label.text = game_title

func _input(event: InputEvent) -> void:
  if menu.visible and event is InputEventMouse:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed('quit'):
    quit()
  elif event.is_action_pressed('start'):
    toggle_menu()
  elif event.is_action_pressed('fullscreen'):
    toggle_fullscreen()
  elif event is InputEventMouseButton:
    track_mouse(event as InputEventMouseButton)

func game_over() -> void:
  is_game_over = true
  toggle_menu()

func reset() -> void:
  is_game_over = false
  set_score(0)

func restart() -> void:
  if menu.visible:
    toggle_menu()
  get_tree().reload_current_scene()

func quit() -> void:
  get_tree().quit.call_deferred()

func toggle_menu() -> void:
  if is_game_over and menu.visible:
    return

  menu.visible = !menu.visible
  get_tree().paused = menu.visible and !is_game_over

  if menu.visible:
    menu_label.text = 'Game Over' if is_game_over else 'Pause'
    button_continue.visible = !is_game_over
    menu.find_next_valid_focus().grab_focus()
  else:
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func toggle_fullscreen() -> void:
  var window := get_window()
  if window.mode == Window.MODE_WINDOWED:
    window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
  else:
    window.mode = Window.MODE_WINDOWED

func track_mouse(event: InputEventMouseButton) -> void:
  if event.pressed:
    mouse_drag = true
    if mouse_start == Vector2.ZERO:
      mouse_start = event.position
  elif mouse_drag:
    mouse_drag = false
    if mouse_start != Vector2.ZERO:
      var input := InputEventAction.new()
      input.pressed = true

      var swipe := event.position - mouse_start
      mouse_start = Vector2.ZERO

      if is_game_over:
        input.action = 'start'
      elif swipe.length() < 20:
        return
      elif abs(swipe.y) > abs(swipe.x):
        input.action = 'up' if swipe.y < 0 else 'down'
      else:
        input.action = 'left' if swipe.x < 0 else 'right'

      Input.parse_input_event(input)

func set_score(value: int) -> void:
  score = value
  score_label.text = 'Score: ' + str(score)

func add_score(value: int) -> void:
  set_score(score + value)

func log(message: String) -> void:
  debug_messages.append(message)
  debug_label.text = "\n".join(debug_messages)
  debug_label.visible = true
  await get_tree().create_timer(2).timeout

  debug_messages.pop_front()
  if debug_messages.size() == 0:
    debug_label.visible = false
  else:
    debug_label.text = "\n".join(debug_messages)
