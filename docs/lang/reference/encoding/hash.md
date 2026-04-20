---
title: Hash
tags:
  - reference
  - encoding
sources:
  - lib/compiler/library/hash/
---

# Hash

**TLDR**: Functions for computing cryptographic hash digests of strings using MD5, SHA1, SHA256, and SHA512 algorithms.

Number of functions: 4

## Functions

### MD5

- **Signature:** `hash.md5(a: String): String`
- **Input:** A string.
- **Output:** The string encoded as MD5.
- **Purity:** Pure
- **Example:**

```
hash.md5("Hello") // returns "8b1a9953c4611296a827abf8c47804d7"
```

### SHA1

- **Signature:** `hash.sha1(a: String): String`
- **Input:** A string.
- **Output:** The string encoded as SHA1.
- **Purity:** Pure
- **Example:**

```
hash.sha1("Hello") // returns "f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0"
```

### SHA256

- **Signature:** `hash.sha256(a: String): String`
- **Input:** A string.
- **Output:** The string encoded as SHA256.
- **Purity:** Pure
- **Example:**

```
hash.sha256("Hello") // returns "185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"
```

### SHA512

- **Signature:** `hash.sha512(a: String): String`
- **Input:** A string.
- **Output:** The string encoded as SHA512.
- **Purity:** Pure
- **Example:**

```
hash.sha512("Hello") // returns "3615f80c9d293ed7402687f94b22d58e529b8cc7916f8fac7fddf7fbd5af4cf777d3d795a7a00a16bf7e7f3fb9561ee9baae480da9fe7a18769e71886b03f315"
```
