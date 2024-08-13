import lexer

type
    Node = ref object of RootObj
    
    Statement = ref object of Node
    
    Expression = ref object of Node
    
    PrimaryExpression = ref object of Expression
    
    Identifier = ref object of PrimaryExpression
        value: string
    

type Parser = ref object of RootObj
    position: uint
    lexemes: ref seq[Lexeme]

proc current(parser: Parser): Lexeme =
    return parser.lexemes[lexer.position]

proc parse_statement(parser: Parser): Statement =
    assert parser.current.type