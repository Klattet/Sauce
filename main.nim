import times, strformat

import lexer

proc main() =
    var source: string = readFile("main.nim")
    var lexer = init_lexer(source)
    
    let start = epochTime()
    lexer.analyse
    let stop = epochTime()
    
    lexer.print_lexemes
    
    echo &"That took {(stop - start):.6f} seconds."

when isMainModule:
    main()