class_name OneShotParticles
extends GPUParticles2D

func _ready() -> void:
  if not visible:
    return

  # The `finished` signal is only triggered after toggling `emitting`
  # https://github.com/godotengine/godot/issues/85802
  emitting = false
  one_shot = true
  emitting = true

  finished.connect(queue_free)
