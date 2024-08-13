import strutils, strformat
import std/sets

type LexemeKind = enum
    String
    Integer
    Float
    Operator
    Identifier

    ParenthesisOpen
    ParenthesisClose
    BracketOpen
    BracketClose
    BraceOpen
    BraceClose
    Comma
    SemiColon

    If
    Else
    Var
    Val

func to_separator(value: char): LexemeKind {.inline.} =
    case value
    of '(': return ParenthesisOpen
    of ')': return ParenthesisClose
    of '[': return BracketOpen
    of ']': return BracketClose
    of '{': return BraceOpen
    of '}': return BraceClose
    of ',': return Comma
    of ';': return SemiColon
    else:
        assert false, "This should never happen"


func to_keyword(value: string): LexemeKind {.inline.} =
    case value
    of "if": return If
    of "else": return Else
    of "var": return Var
    of "val": return Val
    else:
        assert false, "This should never happen"

const SEPS: set[char] = {
    '(',
    ')',
    '[',
    ']',
    '{',
    '}',
    ',',
    ';'
}

const OPS: set[char] = {
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

const KEYWORDS: HashSet[string] = toHashSet([
    "if",
    "else",
    "var",
    "val"
])

const DIGITS: set[char] = { '0'..'9' }

const DIGITS_U: set[char] = { '0'..'9', '_' }

const ALPHAS: set[char] = { 'a'..'z', 'A'..'Z' }

const ALPHAS_U: set[char] = { 'a'..'z', 'A'..'Z', '_' }

const IDENTS: set[char] = { 'a'..'z', 'A'..'Z', '_', '0'..'9' }

const SPACES: set[char] = { ' ', '\n', '\r' }

type Lexeme* = ref object of RootObj
    position*: uint
    length*: uint
    kind*: LexemeKind
    value*: string

type Lexer = ref object of RootObj
    position: uint
    length: uint
    source: string
    lexemes*: seq[Lexeme]

func init_lexer*(source: string): Lexer =
    return Lexer(
        position: 0'u,
        length: uint(source.len),
        source: source,
        lexemes: @[]
    )

proc advance(lexer: Lexer, steps: uint = 1'u): void {.inline.} =
    lexer.position += steps

func finished(lexer: Lexer): bool {.inline.} =
    return lexer.position >= lexer.length

func unfinished(lexer: Lexer): bool {.inline.} =
    return lexer.position < lexer.length

func next(lexer: Lexer): char {.inline.} =
    if lexer.position + 1'u < lexer.length:
        return lexer.source[lexer.position + 1'u]
    else:
        return '\0'

func current(lexer: Lexer): char {.inline.} =
    if lexer.position < lexer.length:
        return lexer.source[lexer.position]
    else:
        return '\0'

func previous(lexer: Lexer): char {.inline.} =
    if lexer.position == 0'u:
        return '\0'
    else:
        return lexer.source[lexer.position - 1'u]

func slice(lexer: Lexer, start_position: uint, end_position: uint): string {.inline.} =
    return lexer.source[start_position..min(end_position, lexer.length) - 1'u]

proc print_lexemes*(lexer: Lexer): void =
    for lexeme in lexer.lexemes:
        echo &"Type: {$lexeme.kind:16} Value: `{lexeme.value}`"

proc skip_spaces(lexer: Lexer): void {.inline.} =
    lexer.advance
    while lexer.current in SPACES:
        lexer.advance

proc eat_separator(lexer: Lexer): void {.inline.} =
    lexer.lexemes.add(
        Lexeme(
            position: lexer.position,
            length: 1'u,
            kind: lexer.current.to_separator,
            value: $lexer.current
        )
    )
    lexer.advance

proc eat_word(lexer: Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.current in IDENTS:
        lexer.advance
    
    let value = lexer.slice(start_position, lexer.position)

    lexer.lexemes.add(
        Lexeme(
            position: start_position,
            length: lexer.position - start_position,
            kind: (if value in KEYWORDS: value.to_keyword else: Identifier),
            value: value
        )
    )

proc eat_operator(lexer: Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.current in OPS:
        lexer.advance

    lexer.lexemes.add(
        Lexeme(
            position: start_position,
            length: lexer.position - start_position,
            kind: Operator,
            value: lexer.slice(start_position, lexer.position)
        )
    )

proc eat_number(lexer: Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.current in DIGITS_U:
        lexer.advance

    assert lexer.previous != '_' and lexer.current notin ALPHAS, "Invalid number format."

    if lexer.current == '.' and lexer.next in DIGITS:
        lexer.advance(2'u)
        while lexer.current in DIGITS_U:
            lexer.advance

        assert lexer.previous != '_' and lexer.current notin ALPHAS, "Invalid number format."

        lexer.lexemes.add(
            Lexeme(
                position: start_position,
                length: lexer.position - start_position,
                kind: Float,
                value: lexer.slice(start_position, lexer.position).multiReplace(("_", ""))
            )
        )
    else:
        lexer.lexemes.add(
            Lexeme(
                position: start_position,
                length: lexer.position - start_position,
                kind: Integer,
                value: lexer.slice(start_position, lexer.position).multiReplace(("_", ""))
            )
        )

proc eat_string(lexer: Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.unfinished and lexer.current != '"':
        lexer.advance(if lexer.current == '\\': 2'u else: 1)

    assert lexer.current == '"', "Invalid string format."

    lexer.advance

    lexer.lexemes.add(
        Lexeme(
            position: start_position,
            length: lexer.position - start_position,
            kind: String,
            value: lexer.slice(start_position + 1'u, lexer.position - 1'u)
        )
    )

proc skip_comment(lexer: Lexer): void {.inline.} =
    lexer.advance
    while lexer.unfinished and lexer.current != '`':
        lexer.advance

    assert lexer.current == '`', "Invalid comment format."

    lexer.advance

proc analyse*(lexer: Lexer): void =
    while lexer.current != '\0':
        
        if lexer.current in SPACES:
            lexer.skip_spaces
        
        elif lexer.current in ALPHAS_U:
            lexer.eat_word
        
        elif lexer.current in SEPS:
            lexer.eat_separator

        elif lexer.current in OPS:
            lexer.eat_operator

        elif lexer.current in DIGITS:
            lexer.eat_number

        elif lexer.current == '"':
            lexer.eat_string

        elif lexer.current == '`':
            lexer.skip_comment

        else:
            assert false, &"Invalid lexeme: `{$lexer.current}`"
