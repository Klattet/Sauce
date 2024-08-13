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

method current(parser: Parser): Lexeme =
    return parser.lexemes[lexer.position]

method parse_statement(parser: Parser): Statement =
    assert parser