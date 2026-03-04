class_name Hud
extends CanvasLayer

var score := 0

@onready var title: Label = %Title
@onready var details: Label = %Details
@onready var gameOver: Control = %GameOver

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
  gameOver.modulate.a = 0.0
  gameOver.visible = true
  var tween := gameOver.create_tween()
  tween.tween_property(gameOver, 'modulate:a', 1, 0.1)

func reset() -> void:
  score = 0
  var tween := gameOver.create_tween()
  tween.tween_property(gameOver, 'modulate:a', 0, 0.1)
  tween.tween_callback(func() -> void: gameOver.visible = false)

func is_game_over() -> bool:
  return gameOver.visible
