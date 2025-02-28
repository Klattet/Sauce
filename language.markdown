---
layout: page
title: Language reference
permalink: /language
type: reference
---

## Lexemes
### Identifier
```py
def test():
    return 0
```

```abnf
identifier = ALPHA *(ALPHA / DIGIT) *("_" 1*(ALPHA / DIGIT))
```

