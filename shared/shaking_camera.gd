class_name ShakingCamera
extends Camera2D

@export var noise: FastNoiseLite

const DECAY := 0.8              # time of shake in seconds
const OFFSET := Vector2(30, 20) # maximum offset in pixels
const ROTATION := 5             # maximum rotation in degrees

var shake := 0.0 # shake amount
var decay := 0.0 # decay time scaled by shake amount

func _process(delta: float) -> void:
  if shake > 0:
    shake = move_toward(shake, 0.0, delta / decay)
    var power := pow(shake, 2)
    var ticks := Time.get_ticks_usec()

    offset.x = roundi(OFFSET.x * power * noise.get_noise_2d(0, ticks))
    offset.y = roundi(OFFSET.y * power * noise.get_noise_2d(100, ticks))
    rotation_degrees = ROTATION * power * noise.get_noise_2d(200, ticks)

func apply_shake(strength: float) -> void:
  shake = clampf(strength, 0.0, 1.0)
  decay = DECAY / shake
  noise.seed = randi()
