import types

type Parser = ref object of RootObj
    position: uint
    lexemes: ref seq[Node]

proc current(parser: Parser): Node =
    return parser.lexemes[parser.position]

proc expect_keyword(lexeme: Node): Keyword =
    assert lexeme of Keyword
