class_name HighScores

const PATH := 'user://hiscores.bin'
const MAX_SCORES := 5

static var games := restore()

static func restore() -> Dictionary[String, Array]:
  var file := FileAccess.open(PATH, FileAccess.READ)
  if not file:
    var error := FileAccess.get_open_error()
    if error != Error.ERR_FILE_NOT_FOUND:
      push_error("Couldn't open %s: %s" % [PATH, error_string(error)])
    return {}

  var data: Variant = file.get_var()
  if data is not Dictionary:
    push_error("Couldn't parse %s: Invalid type %s" % [PATH, type_string(typeof(data))])
    return {}

  var dict: Dictionary[String, Array] = data
  return dict

static func save(score: int) -> Array:
  var game_id := GameInfo.current
  assert(game_id != null)

  if not game_id in games:
    games[game_id] = []

  var scores := games[game_id]

  if score == 0:
    return scores

  scores.append({ score = score })

  var unique := {}
  for entry: Dictionary in scores:
    unique[entry] = null
  scores = unique.keys()

  scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.score > b.score)
  scores.resize(mini(MAX_SCORES, scores.size()))
  games[game_id] = scores

  var file := FileAccess.open(PATH, FileAccess.WRITE)
  if file:
    file.store_var(games)
  else:
    var error := FileAccess.get_open_error()
    push_error("Couldn't write to %s: %s" % [PATH, error_string(error)])

  return scores
