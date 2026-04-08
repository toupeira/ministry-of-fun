class_name Hud
extends CanvasLayer

@onready var title: Label = %Title
@onready var details: Label = %Details
@onready var game_over_panel: Control = %GameOver
@onready var debug_label: Label = %DebugLabel

var score := 0
var is_game_over := false
var debug_messages: Array[String] = []

var touch_drag := false
var touch_start := Vector2.ZERO

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event: InputEvent) -> void:
  if event.is_action_pressed('fullscreen'):
    var window := get_window()
    if window.mode == Window.MODE_WINDOWED:
      window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
    else:
      window.mode = Window.MODE_WINDOWED
  elif event.is_action_pressed('quit'):
    get_tree().quit()
  elif event is InputEventScreenTouch:
    var touch := event as InputEventScreenTouch
    if touch.pressed:
      touch_drag = true
      if touch_start == Vector2.ZERO:
        touch_start = touch.position
    elif touch_drag:
      touch_drag = false
      if touch_start != Vector2.ZERO:
        var input := InputEventAction.new()
        input.pressed = true

        var swipe := touch.position - touch_start
        touch_start = Vector2.ZERO

        if is_game_over:
          input.action = 'start'
        elif swipe.length() < 20:
          return
        elif abs(swipe.y) > abs(swipe.x):
          input.action = 'up' if swipe.y < 0 else 'down'
        else:
          input.action = 'left' if swipe.x < 0 else 'right'

        Input.parse_input_event(input)

func set_title(text: String) -> void:
  title.text = text

func set_details(text: String) -> void:
  details.text = text

func set_score(value: int) -> void:
  score = value
  set_details('Score: ' + str(score))

func add_score(value: int) -> void:
  score += value
  set_score(score)

func game_over() -> void:
  is_game_over = true

  game_over_panel.modulate.a = 0.0
  game_over_panel.visible = true
  var tween := game_over_panel.create_tween()
  tween.tween_property(game_over_panel, 'modulate:a', 1, 0.2)

func reset() -> void:
  score = 0
  is_game_over = false

  var tween := game_over_panel.create_tween()
  tween.tween_property(game_over_panel, 'modulate:a', 0, 0.2)
  tween.tween_callback(func() -> void: game_over_panel.visible = false)

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
