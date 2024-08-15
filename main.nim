import times, strformat

import lexer

proc main() =
    var source: string = readFile("main.nim")
    var lexer: Lexer = init_lexer(source)
    
    let start: float = epochTime()
    lexer.analyse
    let stop: float = epochTime()
    
    lexer.print_lexemes
    
    echo &"That took {(stop - start):.6f} seconds."

when isMainModule:
    main()