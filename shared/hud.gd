class_name Hud
extends CanvasLayer

var score := 0

@onready var title: Label = %Title
@onready var details: Label = %Details
@onready var game_over_panel: Control = %GameOver
@onready var debug_label: Label = %DebugLabel

var debug_messages: Array[String] = []

func _input(event: InputEvent) -> void:
  if event.is_action_pressed('fullscreen'):
    var window := get_window()
    if window.mode == Window.MODE_WINDOWED:
      window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
    else:
      window.mode = Window.MODE_WINDOWED
  elif event.is_action_pressed('quit'):
    get_tree().quit()

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
  game_over_panel.modulate.a = 0.0
  game_over_panel.visible = true
  var tween := game_over_panel.create_tween()
  tween.tween_property(game_over_panel, 'modulate:a', 1, 0.1)

func reset() -> void:
  score = 0
  var tween := game_over_panel.create_tween()
  tween.tween_property(game_over_panel, 'modulate:a', 0, 0.1)
  tween.tween_callback(func() -> void: game_over_panel.visible = false)

func is_game_over() -> bool:
  return game_over_panel.visible

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
