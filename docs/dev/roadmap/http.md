---
title: HTTP
tags: [roadmap, stdlib]
sources: []
---

# HTTP

**TLDR**: Standard library functions for HTTP requests (`http.get`, `http.post`, `http.put`, `http.patch`, `http.delete`) returning `HttpResponse` values with helpers to extract status, body, and headers, addressing the challenge of asynchronous operations in an eager interpreter.

Problem: HTTP requests are asynchronous which complicates how the interpreter expects the evaluation of a term.

```primal
http.get(a: String, b: Map): HttpResponse
```

```primal
http.post(a: String, b: Map, c: String): HttpResponse
```

```primal
http.put(a: String, b: Map, c: String): HttpResponse
```

```primal
http.patch(a: String, b: Map, c: String): HttpResponse
```

```primal
http.delete(a: String, b: Map): HttpResponse
```

```primal
http.status(a: HttpResponse): Number
```

```primal
http.body(a: HttpResponse): String
```

```primal
http.headers(a: HttpResponse): Map
```
