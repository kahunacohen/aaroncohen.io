+++
date = '2021-06-06T14:36:08+03:00'
draft = true
title = 'Evaluating New Tech Project'
tags = ["technology", "programming", "best practices"]
+++

Programmers often face a dilema when coming into an existing project: whether to work with what they have, or start fresh (either entirely or with sections of the code). Because code is harder to read than write, how do we objectively judge how we should approach this dilema? The question is important because we will soon own what we've inherited. 

When reviewing a potential "fix it" project, ask yourself the following questions:

## Are There Docs?

Developers don't like to document their decisions. In addition, out-of-date documentation can be worse than none at all. But the existence and quality of basic documentation (e.g. a README explaining how to install the app etc.) can tell a lot about the general code-quality of a project. If done well (or at all) it reflects well on the orginal developer or team.

## Is the Stack Appropriate?

Evaluate the tech stack against requirements and use-cases. Is the stack optimal for thousands of transactions per second and many users, but the app has ten active users and only a few transactions a day? Does the choice of database make sense given the kind of data? In sum, does the technology match the problem, or was it chosen because it's trendy?

## Are Dependencies Up-to-date?

We're all human, and every project has out-dated dependencies. Our clients don't pay us to update their code. That said, is the framework the app depends upon one or three major versions behind? It's a judgment call, but certainly an out-dated dependency tree is not only insecure, it makes the code harder to work with. The fact that the former developers were careless about this may indicate they were careless in many other ways.

## Is The Code Modular

Is the code broken into reasonably sized modules and functions? Is it clear what each function does based on its name? Are there "[God objects]( https://en.wikipedia.org/wiki/God_object)" or functions? Are modules appropriately scoped/sized?

This alone can tell you a lot about the quality of the project.

## Are Security Best Practices Followed?

A big part of security is ensuring dependencies are up-to-date. Various package managers may have facilities to audit your dependencies. These audits can help ensure there aren't serious security holes lurking in the dependencies. NPM has npm audit, for example.

Also check how sensitive credentials are stored. Are secret tokens or personal information hard-coded in the source code? Hard-coded, sensitive data can indicate ignorance or carelessness.

Look at any place there's user input, such as forms. Confirm data is being validated both client and server-side. Do API endpoints reject malformed data? If not, it shows the developers either were ignorant, careless, or lazy.

## How Easily Reproducible is the Dev Environment?

How easily can you get up and running as a developer? Do you need magical incantations and undocumented packages installed on your host to get the app working in a development environment? If this is a major struggle, imagine what will happen when you really begin working on the code.

## How Are Error/Edge Cases Handled?

Most developers (especially under deadline) focus on the happy path and figure they will come back to error cases when they can. This is the beginning of the end for a project, because under stress the developer never comes back to the code after the happy path is covered.

But error cases often make or break a project because as soon as real users interact with your app, they'll do things you hadn't planned for. That's just the way it is. When I code a feature from scratch I often write the tests for edge cases first. It helps me:

1. think through everything that could go wrong (within reason)  
2. ensure I don't have to "come back" to error cases, because I already handled them!

## Are There Tests?

Now look at automated tests. Are there any? If not, and the app is mature, run far away. Not only will you have no idea what you're breaking as you work, it's a sign of poor craftsmanship.

If there are tests, execute them. Do they pass? Are they testing important things? Are they stable? Run them ten times, and you should get the same result each time. Evaluate the quality of tests and whether distinct units are being tested, how mocks (if any) are used etc. Most importantly, try to write a test for an existing feature. Is it clear how to do so from the existing examples? Is it easy to do?  

Extra points, of course, if the project has CI/CD.

## Does the App Work?

This may seem obvious, but run through various user flows and see if you can break the app. Is the app reliable?

## Conclusion

It's often not clear-cut, when inheriting a project, whether you should work with what you have or start fresh. Sometimes only working with code for many weeks (or more) will tell you for sure, and by then it may be too late.

That said, spending a day carefully evaluating the state of a project before taking it on is effort well spent. If you're handed an app that simply doesn't work well AND it's hard to write a few meaningful tests, then you could be in for a world of pain. Estimate the time it would take to rewrite the app from scratch and be prepared to discuss with the client the current state of the project and the options if the project is in bad condition.

And when you work on any project, consider that someone may be inheriting your project someday—maybe sooner than you think. It's easier to start a project right from the beginning than to rein in a wild one.

