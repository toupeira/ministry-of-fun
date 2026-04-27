class_name GameInfo

static var current: String

static var games: Dictionary[String, Dictionary] = {
  snake = {
    name = "Snake",
    genre = "Action",
    description = "Eat apples to grow your snake and avoid obstacles!",
    history = ' '.join([
      'Inspired by the arcade game "Blockade" released by Gremlin Industries in 1976,',
      '"Snake" became widely popular when it was launched on Nokia mobile phones in 1997.'
    ]),
  },
}
