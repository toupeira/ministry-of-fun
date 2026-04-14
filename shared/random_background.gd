@tool
extends TextureRect

const backgrounds: Array[Texture2D] = [
  preload('res://assets/backgrounds/City Backgrounds/city 1/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 2/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 3/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 4/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 5/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 6/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 7/origbig.png'),
  preload('res://assets/backgrounds/City Backgrounds/city 8/origbig.png'),
  preload('res://assets/backgrounds/Nature Landscapes/nature 2/origbig.png'),
  preload('res://assets/backgrounds/Nature Landscapes/nature 3/origbig.png'),
  preload('res://assets/backgrounds/Nature Landscapes/nature 4/origbig.png'),
  preload('res://assets/backgrounds/Nature Landscapes/nature 5/origbig.png'),
  preload('res://assets/backgrounds/Nature Landscapes/nature 6/origbig.png'),
  preload('res://assets/backgrounds/Nature Landscapes/nature 8/origbig.png'),
  preload('res://assets/backgrounds/Summer Backgrounds/summer 2/origbig.png'),
  preload('res://assets/backgrounds/Summer Backgrounds/summer 4/origbig.png'),
  preload('res://assets/backgrounds/Summer Backgrounds/summer 5/origbig.png'),
  preload('res://assets/backgrounds/Summer Backgrounds/summer 6/origbig.png'),
  preload('res://assets/backgrounds/Summer Backgrounds/summer 7/origbig.png'),
  preload('res://assets/backgrounds/Summer Backgrounds/summer 8/origbig.png'),
]

func _ready() -> void:
  var background: Texture2D = backgrounds.pick_random()
  set_texture(background)
