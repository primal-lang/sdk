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
