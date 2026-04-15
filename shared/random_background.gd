@tool
extends TextureRect

const backgrounds: Array[Texture2D] = [
  preload('res://assets/backgrounds/city/city1.png'),
  preload('res://assets/backgrounds/city/city2.png'),
  preload('res://assets/backgrounds/city/city3.png'),
  preload('res://assets/backgrounds/city/city4.png'),
  preload('res://assets/backgrounds/city/city5.png'),
  preload('res://assets/backgrounds/city/city6.png'),
  preload('res://assets/backgrounds/city/city7.png'),
  preload('res://assets/backgrounds/city/city8.png'),
  preload('res://assets/backgrounds/nature/nature2.png'),
  preload('res://assets/backgrounds/nature/nature3.png'),
  preload('res://assets/backgrounds/nature/nature4.png'),
  preload('res://assets/backgrounds/nature/nature5.png'),
  preload('res://assets/backgrounds/nature/nature6.png'),
  preload('res://assets/backgrounds/nature/nature8.png'),
  preload('res://assets/backgrounds/summer/summer2.png'),
  preload('res://assets/backgrounds/summer/summer4.png'),
  preload('res://assets/backgrounds/summer/summer5.png'),
  preload('res://assets/backgrounds/summer/summer6.png'),
  preload('res://assets/backgrounds/summer/summer7.png'),
  preload('res://assets/backgrounds/summer/summer8.png'),
]

func _ready() -> void:
  var background: Texture2D = backgrounds.pick_random()
  set_texture(background)
