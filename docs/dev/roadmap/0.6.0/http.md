---
title: HTTP
tags:
  - roadmap
  - stdlib
sources: []
---

# HTTP

**TLDR**: Standard library functions for HTTP requests (`http_get`, `http_post`, `http_put`, `http_patch`, `http_delete`) returning `HttpResponse` values with helpers to extract status, body, and headers, addressing the challenge of asynchronous operations in an eager interpreter.

Problem: HTTP requests are asynchronous which complicates how the interpreter expects the evaluation of a term.

```primal
http_get(a: String, b: Map): HttpResponse
```

```primal
http_post(a: String, b: Map, c: String): HttpResponse
```

```primal
http_put(a: String, b: Map, c: String): HttpResponse
```

```primal
http_patch(a: String, b: Map, c: String): HttpResponse
```

```primal
http_delete(a: String, b: Map): HttpResponse
```

```primal
http_status(a: HttpResponse): Number
```

```primal
http_body(a: HttpResponse): String
```

```primal
http_headers(a: HttpResponse): Map
```
