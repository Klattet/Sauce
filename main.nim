import times, strutils, strformat

import lexer

proc main() =
    let source = readFile("main.nim")
    var lexer = init_lexer(source)
    
    let start = epochTime()
    lexer.analyse
    let stop = epochTime()
    
    lexer.print_lexemes
    
    echo &"That took {(stop - start):.6f} seconds."

main()
