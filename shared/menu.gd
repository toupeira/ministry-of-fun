class_name Menu
extends Control

@onready var shadow: Control = %Shadow
@onready var title: Label = %MenuTitle
@onready var button_continue: Button = %ButtonContinue

func toggle(is_game_over: bool) -> void:
  if is_game_over and visible:
    return

  visible = !visible
  get_tree().paused = visible and !is_game_over

  if visible:
    title.text = 'Game Over' if is_game_over else 'Pause'
    button_continue.visible = !is_game_over
    find_next_valid_focus().grab_focus()
  else:
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event: InputEvent) -> void:
  if visible and event is InputEventMouse:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_continue_pressed() -> void:
  toggle(false)

func _on_button_restart_pressed() -> void:
  toggle(false)
  get_tree().reload_current_scene()

func _on_button_quit_pressed() -> void:
  get_tree().quit()
