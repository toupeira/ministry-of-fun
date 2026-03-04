extends Node2D

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
  get_tree().change_scene_to_file.call_deferred("res://snake/snake.tscn")
