import typetraits
import strformat
import std/sets
import strutils

import types

type Lexer = ref object of RootObj
    position: uint
    length: uint
    source: string
    lexemes*: seq[Node]

func init_lexer*(source: var string): Lexer =
    return Lexer(
        position: 0'u,
        length: uint(source.len),
        source: source,
        lexemes: @[]
    )

proc advance(lexer: var Lexer, steps: uint = 1'u): void {.inline.} =
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
    return lexer.source[start_position..<min(end_position, lexer.length)]

proc print_lexemes*(lexer: Lexer): void =
    for lexeme in lexer.lexemes:
        if lexeme of String:
            echo &"{cast[String](lexeme).type.name}: {cast[String](lexeme).value}"
        elif lexeme of Integer:
            echo &"{cast[Integer](lexeme).type.name}: {cast[Integer](lexeme).value}"
        elif lexeme of Float:
            echo &"{cast[Float](lexeme).type.name}: {cast[Float](lexeme).value}"
        elif lexeme of Operator:
            echo &"{cast[Operator](lexeme).type.name}: {cast[Operator](lexeme).value}"
        elif lexeme of Identifier:
            echo &"{cast[Identifier](lexeme).type.name}: {cast[Identifier](lexeme).value}"
        elif lexeme of Separator:
            echo &"{cast[Separator](lexeme).type.name}: {$cast[Separator](lexeme).kind}"
        elif lexeme of Keyword:
            echo &"{cast[Keyword](lexeme).type.name}: {$cast[Keyword](lexeme).kind}"
        else:
            assert false, "Node shouldn't be here."

proc skip_spaces(lexer: var Lexer): void {.inline.} =
    lexer.advance
    while lexer.current in SPACE_LITERALS:
        lexer.advance

proc skip_comment(lexer: var Lexer): void {.inline.} =
    lexer.advance
    while lexer.unfinished and lexer.current != '`':
        lexer.advance
    
    assert lexer.current == '`', "Invalid comment format."
    
    lexer.advance

proc eat_separator(lexer: var Lexer): void {.inline.} =
    {.warning[HoleEnumConv]:off.}
    lexer.lexemes.add(
        Separator(
            source: lexer.source,
            position: lexer.position,
            length: 1'u,
            kind: SeparatorKind(lexer.current)
        )
    )
    lexer.advance
    #{.warning[HoleEnumConv]:on.}

proc eat_word(lexer: var Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.current in IDENT_LITERALS:
        lexer.advance
    
    let value: string = lexer.slice(start_position, lexer.position)
    
    if value in KEYWORD_LITERALS:
        lexer.lexemes.add(
            Keyword(
                source: lexer.source,
                position: start_position,
                length: lexer.position - start_position,
                kind: parseEnum[KeywordKind](value)
            )
        )
    else:
        lexer.lexemes.add(
            Identifier(
                source: lexer.source,
                position: start_position,
                length: lexer.position - start_position,
                value: value
            )
        )
        

proc eat_operator(lexer: var Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.current in OPERATOR_LITERALS:
        lexer.advance

    lexer.lexemes.add(
        Operator(
            source: lexer.source,
            position: start_position,
            length: lexer.position - start_position,
            value: lexer.slice(start_position, lexer.position)
        )
    )

proc eat_number(lexer: var Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.current in DIGIT_UNDERSCORE_LITERALS:
        lexer.advance

    assert lexer.previous != '_' and lexer.current notin ALPHA_LITERALS, "Invalid number format."

    if lexer.current == '.' and lexer.next in DIGIT_LITERALS:
        lexer.advance(2'u)
        while lexer.current in DIGIT_UNDERSCORE_LITERALS:
            lexer.advance

        assert lexer.previous != '_' and lexer.current notin ALPHA_LITERALS, "Invalid number format."

        lexer.lexemes.add(
            Float(
                source: lexer.source,
                position: start_position,
                length: lexer.position - start_position,
                value: lexer.slice(start_position, lexer.position).multiReplace(("_", ""))
            )
        )
    else:
        lexer.lexemes.add(
            Integer(
                source: lexer.source,
                position: start_position,
                length: lexer.position - start_position,
                value: lexer.slice(start_position, lexer.position).multiReplace(("_", ""))
            )
        )

proc eat_string(lexer: var Lexer): void {.inline.} =
    let start_position: uint = lexer.position
    lexer.advance
    while lexer.unfinished and lexer.current != '"':
        lexer.advance(if lexer.current == '\\': 2'u else: 1'u)

    assert lexer.current == '"', "Invalid string format."

    lexer.advance

    lexer.lexemes.add(
        String(
            source: lexer.source,
            position: start_position,
            length: lexer.position - start_position,
            value: lexer.slice(start_position + 1'u, lexer.position - 1'u)
        )
    )

proc analyse*(lexer: var Lexer): void =
    while lexer.current != '\0':
        
        if lexer.current in SPACE_LITERALS:
            lexer.skip_spaces
        
        elif lexer.current in ALPHA_UNDERSCORE_LITERALS:
            lexer.eat_word
        
        elif lexer.current in SEPARATOR_LITERALS:
            lexer.eat_separator

        elif lexer.current in OPERATOR_LITERALS:
            lexer.eat_operator

        elif lexer.current in DIGIT_LITERALS:
            lexer.eat_number

        elif lexer.current == '"':
            lexer.eat_string

        elif lexer.current == '`':
            lexer.skip_comment

        else:
            assert false, &"Invalid lexeme: `{$lexer.current}`"
