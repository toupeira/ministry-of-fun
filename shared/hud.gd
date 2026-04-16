class_name Hud
extends CanvasLayer

@onready var title: Label = %Title
@onready var details: Label = %Details
@onready var menu: Menu = %Menu
@onready var debug_label: Label = %DebugLabel

var score := 0
var is_game_over := false
var debug_messages: Array[String] = []

var click_drag := false
var click_start := Vector2.ZERO

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event: InputEvent) -> void:
  if event.is_action_pressed('quit'):
    menu.quit()
  elif event.is_action_pressed('start'):
    menu.toggle(is_game_over)
  elif event.is_action_pressed('fullscreen'):
    menu.toggle_fullscreen()
  elif event is InputEventMouseButton:
    var click := event as InputEventMouseButton
    if click.pressed:
      click_drag = true
      if click_start == Vector2.ZERO:
        click_start = click.position
    elif click_drag:
      click_drag = false
      if click_start != Vector2.ZERO:
        var input := InputEventAction.new()
        input.pressed = true

        var swipe := click.position - click_start
        click_start = Vector2.ZERO

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
  set_score(score + value)

func game_over() -> void:
  is_game_over = true
  menu.toggle(is_game_over)

func reset() -> void:
  set_score(0)
  is_game_over = false

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
