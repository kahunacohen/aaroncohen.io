+++
date = '2021-07-07T15:11:40+03:00'
draft = true
title = 'Golang: a Python Killer?'
tags = ["programming", "technology", "golang"]
+++

[Golang](https://go.dev/) is a newer-generation (2009) multi-purpose programming language developed by Google to address the challenges of software-development at-scale and concurrent programming.

The most well-known projects written in Go are Docker and Kubernetes, but many other essential cloud-native tools are also written in Go, including [Terraform](https://developer.hashicorp.com/terraform) and [influxdb](https://www.influxdata.com/).

Though most cloud providers provide Go SDKs, in general the Go ecosystem is minimal. One of the reasons for this is that Go's standard libraries (e.g. net/http) are more than sufficient for most use-cases. That said, there's no killer, batteries-included server framework like [Express](https://expressjs.com/), [Rails](https://rubyonrails.org/), or [Django](https://www.djangoproject.com/) that provides a seamless developer experience. So, if your developing a standard, relatively simple API server, I wouldn't use Go unless you have a good reason to (such as concurrency/performance considerations).

That said, Go hits a particular sweet-spot where Python used to rule: writing CLI applications. I've used Python for this before because:

1. it just helps get things done.  
2. batteries are included. Either the standard Python libraries are enough, or there were plenty of well-vetted, quality libraries to help.  
3. it's readable.  
4. a lot of people know it.

Go hits all these marks, but it adds a few killer features. For one, It's typed, which catches a lot of errors before run-time. Go's typing strikes a lovely balance between safety and staying out of your way.  

Secondly, it compiles to a binary, allowing you to distribute an executable and not worry about a run-time.

Thirdly, it has first-class asynchronous types (channels) which can massively ease asynchronous network development.

And finally, in some ways, it's even simpler than Python. It's not a sexy, or expressive language at all. There's usually one (simple) way to do things. For example, there are no exceptions. Functions that can fail, by convention, return a two-member tuple, with the last one being an error. The compiler will warn you if don't handle both values returned by such functions.

There is no ternary operator, ~~no generics~~, nor classical inheritance. The simpler constructs and syntax allows you to "[fall into the pit of success](https://blog.codinghorror.com/falling-into-the-pit-of-success/)." You'll have to do it the "Go way," or use some other language. This is by design. With Go, you won't impress the world with clever one-liners. But in a month, when you (or someone else) re-reads your code, the lack of "cleverness" will likely prove to be a very good thing.

Especially for CLIs that you suspect will stay around for a while, and where dirty shell scripts won't cut it, Go offers a perfect balance: portability, speed, and compile-time checks, yet it allows you to get things done--quickly.
