---
layout: page
title: Language reference
permalink: /language
type: reference
---

## Lexemes
### Identifier
{% highlight python %}
def test():
    return 0
{% endhighlight %}

{% highlight abnf %}
identifier = ALPHA *(ALPHA / DIGIT) *("_" 1*(ALPHA / DIGIT))
{% endhighlight %}
