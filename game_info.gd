class_name GameInfo

static var current: String

static var games: Dictionary[String, Dictionary] = {
  main = {
    name = "Ministry of Fun",
    hidden = true,
  },
  snake = {
    name = "Snake",
    genre = "Action",
    description = "Eat apples to grow your snake and avoid obstacles!",
    history = '\n'.join([
      '"Snake" became widely popular when it was launched on Nokia mobile phones in 1997.',
      'It was based on the arcade game "Blockade", released by Gremlin Industries in 1976.',
    ]),
  },
}
