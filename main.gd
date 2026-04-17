extends Node

func _ready() -> void:
  RenderingServer.set_default_clear_color(Color.BLACK)

  # Wait for shaders to compile
  await get_tree().process_frame
  await get_tree().process_frame

  get_tree().change_scene_to_file.call_deferred("res://snake/snake.tscn")
