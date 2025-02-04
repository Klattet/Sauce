import types

type Parser = ref object of RootObj
    position: uint
    lexemes: var seq[Node]
    length: uint

func init_parser(lexemes: var seq[Node]): Parser =
    return Parser(
        position: 0'u,
        length: uint(lexemes.len),
        lexemes: lexemes
    )

func current(parser: Parser): Node =
    assert parser.position < parser.length, "Out of bounds on current."
    return parser.lexemes[parser.position]

func expect_kind(lexeme: Node, kinds: varargs[typedesc[Node]]): typedesc[Node] =
    for kind in kinds:
        if lexeme of kind:
            return kind
    assert false, "Unexpected lexemes."

func expect_keyword(lexeme: Node, kind: KeywordKind): Keyword =
    assert lexeme of Keyword, "Expected a keyword."
    assert cast[Keyword](lexeme).kind == kind, "Unexpected keyword kind."
    return cast[Keyword](lexeme)

proc parse_val_statement(parser: var Parser, keyword: Keyword): Statement =
    discard
    

proc parse_statement(parser: var Parser): Statement =
    let keyword: Keyword = expect_keyword(parser.current, Keyword)


proc parse_block(parser: var Parser): Block =
    while not (parser.current of EndOfFile):
        discard