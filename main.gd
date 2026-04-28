extends Node

@onready var game_list: ItemList = %GameList
@onready var game_info: RichTextLabel = %GameInfo

func _ready() -> void:
  get_tree().change_scene_to_file.call_deferred('res://snake/snake.tscn')
  return

  for game_id in GameInfo.games:
    var game := GameInfo.games[game_id]
    if game.get('hidden', false):
      continue

    var game_name: String = game.name
    var index := game_list.add_item(game_name)
    game_list.set_item_metadata(index, game_id)
    game_list.set_item_tooltip_enabled(index, false)

  game_list.grab_focus()
  game_list.select(0)

func _input(event: InputEvent) -> void:
  if event is InputEventMouse:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_game_list_item_selected(index: int) -> void:
  var game_id: String = game_list.get_item_metadata(index)
  var game := GameInfo.games[game_id]
  game_info.text = "[font_size=12][color=#aaa]Description:[/color][/font_size]\n%s\n\n[font_size=12][color=#aaa]History:[/color][/font_size]\n%s" % [
    game.get('description', ''),
    game.get('history', '')
  ]

func _on_game_list_item_activated(index: int) -> void:
  var game_id: String = game_list.get_item_metadata(index)
  get_tree().change_scene_to_file('res://%s/%s.tscn' % [game_id, game_id])
