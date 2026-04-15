extends Node

func _ready() -> void:
  RenderingServer.set_default_clear_color(Color.BLACK)
  get_tree().change_scene_to_file.call_deferred("res://snake/snake.tscn")
