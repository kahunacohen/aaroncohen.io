+++
date = '2021-07-08T00:00:00+00:00'
draft = true
title = 'Abstractions'
+++

We rely on abstractions to make sense of the world. Your dog is not really a "dog." There's no such thing. The word is a generalization for a group of entities that share a similar genetic make-up. But it's easier to just say, "dog," and we all understand because we generally agree on the things the word stands for.

Sometimes abstractions fail to sufficiently account for what they intend to describe. This is called a leaky abstraction and becomes more problematic as we attempt to pidgeonhole more and more concrete things into the abstraction.

Software development is full of abstractions. We couldn't do without them. Yet leaky abstractions are particularly problematic because they negatively affect productivity. Joel Spolsky has famously discussed this years ago.

One of the keys to a successful software project is appropriate levels of abstraction. We must know when to make an abstraction and when not to. This skill is related to knowing when not to optimize. I'm not saying not to abstract or optimize. That would be silly. I'm saying to do it at the right time, and only when you need to. Knowing the right time and when is the rub.

Writing the same code over and over again may be a sign that an abstraction is called for, whether a function, class, module, or whatever. But, first, make sure doing it the ugly way hurts first. Until it hurts you don't enough about the problem to effectively solve it with an abstraction.

Even simple abstractions don't always cover edge cases, and you'll likely need to modify your abstraction or create yet another one to salvage your original one. This happens most often when parameterizing functions. It's not always a bad thing to add parameters to a function to cover edge-cases, but do think about whether your original function is really an appropriate abstraction in the first place. Why? Because as a function's parameter list grows it becomes more complex for the caller and harder to debug. It's a sign that the original details it was supposed to hide are more complex than you thought.

Software abstractions can also be problematic when the person reading your code wants to know the implementation details without following multiple levels of function calls, especially if the abstraction doesn't do that much. Abstractions that are too shallow simply hide reality for no good reason.

On the other hand, think twice if the abstraction is deep. Unless you're careful, you are hiding complexity by making another complex thing, which in turn makes the whole project more complex. That's not necessarily a good thing. You're kicking the can down the road. Again, creating a complex abstraction may be called-for. Perhaps the can belongs down the road. This is a judgment call, and no blog post or class can teach you when to make abstractions as you code. But do be aware that nothing is free in software development.

Finally, dependencies are a form of abstraction. A dependency that doesn't pull its weight is too shallow an abstraction. Relying on these types of dependencies is penny-wise and pound foolish because you've just introduced a possible catastrophic vulnerability in order to save yourself a few minutes, or because you're under the illusion that copying and pasting code is always bad. It's not.

Also, dependencies that abstract over details that you don't understand can be problematic. Of course, we can't know everything. However, within your domain, you should at least understand what the dependency is doing for you.

Our tools of the trade are there for a reason, and we shouldn't be shy about using them when appropriate. But stop for a moment before reaching into the toolbox, and think about whether you need the tool you're about to use, or whether it's simpler, faster and more effective to use your hands (at least for now).

