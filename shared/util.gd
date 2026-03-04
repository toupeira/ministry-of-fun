class_name Util
extends Node

static func grow_and_fade(node: Node, size := 4.0, speed := 0.25) -> Tween:
  var tween := node.create_tween()
  tween.tween_property(node, 'scale', Vector2(size, size), speed)
  tween.tween_property(node, 'modulate:a', 0.0, speed)
  tween.tween_callback(node.queue_free)
  return tween

static func get_tile_position(tilemap: TileMapLayer, pos :Vector2i) -> Vector2i:
  var local := tilemap.map_to_local(pos)
  return tilemap.to_global(local)

static func get_tile_image(tilemap: TileMapLayer, pos: Vector2i) -> ImageTexture:
  var source_id := tilemap.get_cell_source_id(pos)
  var source: TileSetAtlasSource = tilemap.tile_set.get_source(source_id)
  var atlas_pos := tilemap.get_cell_atlas_coords(pos)
  var rect := source.get_tile_texture_region(atlas_pos)
  var image: Image = source.texture.get_image()
  var tile_image := image.get_region(rect)

  return ImageTexture.create_from_image(tile_image)
