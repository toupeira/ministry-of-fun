class_name Menu
extends Control

@onready var shadow: Control = %Shadow
@onready var title: Label = %MenuTitle

@onready var button_continue: Button = %ButtonContinue
@onready var button_restart: Button = %ButtonRestart
@onready var button_quit: Button = %ButtonQuit

func _ready() -> void:
  button_quit.visible = OS.get_name() != 'Web'

func quit() -> void:
  get_tree().quit.call_deferred()

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

func toggle_fullscreen() -> void:
  var window := get_window()
  if window.mode == Window.MODE_WINDOWED:
    window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
  else:
    window.mode = Window.MODE_WINDOWED

func _input(event: InputEvent) -> void:
  if visible and event is InputEventMouse:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_continue_pressed() -> void:
  toggle(false)

func _on_button_restart_pressed() -> void:
  toggle(false)
  get_tree().reload_current_scene()

func _on_button_quit_pressed() -> void:
  quit()
