import std/sets

const DIGIT_LITERALS*: set[char] = { '0'..'9' }

const DIGIT_UNDERSCORE_LITERALS*: set[char] = { '0'..'9', '_' }

const ALPHA_LITERALS*: set[char] = { 'a'..'z', 'A'..'Z' }

const ALPHA_UNDERSCORE_LITERALS*: set[char] = { 'a'..'z', 'A'..'Z', '_' }

const IDENT_LITERALS*: set[char] = { 'a'..'z', 'A'..'Z', '_', '0'..'9' }

const SPACE_LITERALS*: set[char] = { ' ', '\n', '\r' }

const OPERATOR_LITERALS*: set[char] = {
    '\'',
    '=',
    '+',
    '-',
    '^',
    '~',
    '*',
    '@',
    '!',
    '?',
    '#',
    '$',
    '&',
    '\\',
    '/',
    '|',
    '<',
    '>',
    '.',
    ':'
}

type SeparatorKind* = enum
    ParenthesisOpen  = '('
    ParenthesisClose = ')'
    Comma            = ','
    SemiColon        = ';'
    BracketOpen      = '['
    BracketClose     = ']'
    BraceOpen        = '{'
    BraceClose       = '}'

const SEPARATOR_LITERALS*: set[char] = {
    ',',
    ';',
    '(',
    ')',
    '[',
    ']',
    '{',
    '}'
}

type KeywordKind* = enum
    If   = "if"
    Else = "else"
    Var  = "var"
    Val  = "val"

let KEYWORD_LITERALS*: HashSet[string] = toHashSet([
    "if",
    "else",
    "var",
    "val"
])

type
    Node* = ref object of RootObj
        source*: string
        position*: uint
        length*: uint

    Expression* = ref object of Node
    
    PrimaryExpression* = ref object of Expression
        value*: string
    
    String* = ref object of PrimaryExpression
    Integer* = ref object of PrimaryExpression
    Float* = ref object of PrimaryExpression
    Operator* = ref object of PrimaryExpression
    Identifier* = ref object of PrimaryExpression
    
    Separator* = ref object of Node
        kind*: SeparatorKind
    
    Keyword* = ref object of Node
        kind*: KeywordKind
    
    