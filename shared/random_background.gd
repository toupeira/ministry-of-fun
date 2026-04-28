extends TextureRect

const backgrounds: Array[Texture2D] = [
  preload('res://assets/thirdparty/backgrounds/city/city1.png'),
  preload('res://assets/thirdparty/backgrounds/city/city2.png'),
  preload('res://assets/thirdparty/backgrounds/city/city3.png'),
  preload('res://assets/thirdparty/backgrounds/city/city4.png'),
  preload('res://assets/thirdparty/backgrounds/city/city5.png'),
  preload('res://assets/thirdparty/backgrounds/city/city6.png'),
  preload('res://assets/thirdparty/backgrounds/city/city7.png'),
  preload('res://assets/thirdparty/backgrounds/city/city8.png'),
  preload('res://assets/thirdparty/backgrounds/nature/nature2.png'),
  preload('res://assets/thirdparty/backgrounds/nature/nature3.png'),
  preload('res://assets/thirdparty/backgrounds/nature/nature4.png'),
  preload('res://assets/thirdparty/backgrounds/nature/nature5.png'),
  preload('res://assets/thirdparty/backgrounds/nature/nature6.png'),
  preload('res://assets/thirdparty/backgrounds/nature/nature8.png'),
  preload('res://assets/thirdparty/backgrounds/summer/summer2.png'),
  preload('res://assets/thirdparty/backgrounds/summer/summer4.png'),
  preload('res://assets/thirdparty/backgrounds/summer/summer5.png'),
  preload('res://assets/thirdparty/backgrounds/summer/summer7.png'),
  preload('res://assets/thirdparty/backgrounds/summer/summer8.png'),
]

func _ready() -> void:
  var background: Texture2D = backgrounds.pick_random()
  set_texture(background)
