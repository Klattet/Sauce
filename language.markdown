---
layout: page
title: Language reference
permalink: /language
type: reference
---

{% highlight python %}
def test():
return 0
{% endhighlight %}

## Lexemes
### Identifier

{% highlight abnf %}
identifier = ALPHA *(ALPHA / DIGIT) *("_" 1*(ALPHA / DIGIT))
{% endhighlight %}
