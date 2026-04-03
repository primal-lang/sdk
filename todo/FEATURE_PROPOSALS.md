# Feature Proposals for Primal

This document contains proposed features for the Primal programming language that extend beyond the current feature set. Each proposal includes an assessment of how well it fits Primal's design philosophy, implementation complexity, and potential impact.

**Rating Scale:**

- **Fit**: How well the feature aligns with Primal's functional, immutable, lazy-evaluated nature
- **Complexity**: Implementation effort required
- **Impact**: Value delivered to users

---

## Table of Contents

1. [Data Types & Structures](#data-types--structures)
   - [Complex Numbers](#1-complex-numbers)
   - [Rationals](#2-rationals)
   - [Matrices](#3-matrices)
   - [Graph Type](#4-graph-type)
   - [Tree Type](#5-tree-type)
   - [NonEmpty Collections](#6-nonempty-collections)
   - [Difference Lists](#7-difference-lists)
   - [Finger Trees](#8-finger-trees)
   - [Tries / Prefix Trees](#9-tries--prefix-trees)
   - [Persistent Vectors](#10-persistent-vectors)

2. [Functional Programming Patterns](#functional-programming-patterns)
   - [Lenses / Optics](#11-lenses--optics)
   - [Transducers](#12-transducers)
   - [Trampolining](#13-trampolining)
   - [Codata / Corecursion](#14-codata--corecursion)
   - [First-Class Patterns](#15-first-class-patterns)
   - [Active Patterns](#16-active-patterns)
   - [Monoid / Semigroup Operations](#17-monoid--semigroup-operations)
   - [Functors and Applicatives](#18-functors-and-applicatives)

3. [Effects & Control Flow](#effects--control-flow)
   - [Algebraic Effects / Effect Handlers](#19-algebraic-effects--effect-handlers)
   - [Delimited Continuations](#20-delimited-continuations)
   - [Validation Type](#21-validation-type)
   - [Implicit Parameters](#22-implicit-parameters)
   - [Async / Promises](#23-async--promises)
   - [Streams / Observables](#24-streams--observables)

4. [Type System Enhancements](#type-system-enhancements)
   - [Units of Measure](#25-units-of-measure)
   - [Nominal Newtypes](#26-nominal-newtypes)
   - [Row Polymorphism](#27-row-polymorphism)
   - [Linear / Affine Types](#28-linear--affine-types)
   - [Phantom Types](#29-phantom-types)
   - [Refinement Types](#30-refinement-types)

5. [Language Primitives](#language-primitives)
   - [Symbols / Atoms](#31-symbols--atoms)
   - [Quotation / Quasi-quotation](#32-quotation--quasi-quotation)
   - [Multi-methods](#33-multi-methods)
   - [Debug / Trace Expressions](#34-debug--trace-expressions)
   - [First-Class Environments](#35-first-class-environments)
   - [Keyword Arguments as Values](#36-keyword-arguments-as-values)

6. [Testing & Verification](#testing--verification)
   - [Property-Based Testing](#37-property-based-testing)
   - [Soft Invariants / Contracts](#38-soft-invariants--contracts)
   - [Snapshot Testing](#39-snapshot-testing)

7. [Syntax Sugar & Ergonomics](#syntax-sugar--ergonomics)
   - [Case Expressions](#40-case-expressions)
   - [When Expressions](#41-when-expressions)
   - [With Expressions](#42-with-expressions)
   - [Placeholder Arguments](#43-placeholder-arguments)
   - [Method Chaining Syntax](#44-method-chaining-syntax)

---

## Data Types & Structures

### 1. Complex Numbers

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Native support for complex numbers with real and imaginary parts. Complex numbers are essential for scientific computing, signal processing, and mathematical applications.

**Proposed Syntax:**

```primal
// Literal syntax
z1 = 3 + 4i
z2 = 2 - 1i
z3 = 5i          // pure imaginary
z4 = 3.14 + 2.71i  // decimal components

// Operations
sum = z1 + z2           // (5 + 3i)
product = z1 * z2       // (6 + 8i + (-4i) + (-4i²)) = (10 + 5i)
quotient = z1 / z2      // complex division

// Standard library functions
complex.real(z1)        // 3
complex.imag(z1)        // 4
complex.conjugate(z1)   // 3 - 4i
complex.magnitude(z1)   // 5 (sqrt(3² + 4²))
complex.phase(z1)       // angle in radians
complex.polar(r, theta) // create from polar form
complex.fromReal(5)     // 5 + 0i
```

**Use Cases:**

- Electrical engineering (AC circuits, impedance)
- Signal processing (Fourier transforms)
- Quantum computing simulations
- Fractal generation (Mandelbrot set)
- Control systems

**Implementation Notes:**

- Add `ComplexNode` to runtime nodes
- Extend number parsing in lexer to recognize `i` suffix
- Implement arithmetic with complex number rules
- Add `complex.*` namespace to standard library

---

### 2. Rationals

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Exact rational number arithmetic using numerator/denominator pairs. Avoids floating-point precision errors that plague decimal arithmetic.

**Proposed Syntax:**

```primal
// Literal syntax using fraction notation
r1 = 1/3
r2 = 2/6          // automatically simplified to 1/3
r3 = 22/7         // approximation of pi

// Operations preserve exactness
sum = 1/3 + 1/6   // = 1/2 (exact, not 0.4999...)
product = 2/3 * 3/4  // = 1/2

// Comparison
1/3 == 2/6        // true (after normalization)

// Standard library functions
rational.numerator(r1)    // 1
rational.denominator(r1)  // 3
rational.simplify(4/8)    // 1/2
rational.toDecimal(1/3)   // 0.333...
rational.fromDecimal(0.5) // 1/2
rational.reciprocal(2/3)  // 3/2
rational.isInteger(4/2)   // true
rational.floor(7/3)       // 2
rational.ceil(7/3)        // 3
```

**Use Cases:**

- Financial calculations requiring exact arithmetic
- Mathematical computations
- Ratio and proportion problems
- Music theory (time signatures, intervals)
- Recipe scaling

**Implementation Notes:**

- Store as pair of integers (numerator, denominator)
- Always keep in lowest terms (GCD normalization)
- Handle sign consistently (numerator carries sign)
- Prevent division by zero in denominator

---

### 3. Matrices

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
First-class 2D matrices with linear algebra operations. Extends the existing `vector` type to two dimensions.

**Proposed Syntax:**

```primal
// Creation
m1 = matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
m2 = matrix.identity(3)       // 3x3 identity matrix
m3 = matrix.zeros(2, 3)       // 2x3 zero matrix
m4 = matrix.ones(3, 2)        // 3x2 matrix of ones
m5 = matrix.diagonal([1, 2, 3])  // diagonal matrix
m6 = matrix.fromRows([[1, 2], [3, 4]])
m7 = matrix.fromCols([[1, 3], [2, 4]])

// Element access
matrix.at(m1, 0, 1)           // element at row 0, col 1 = 2
matrix.row(m1, 0)             // [1, 2, 3]
matrix.col(m1, 1)             // [2, 5, 8]
matrix.set(m1, 0, 0, 10)      // immutable update

// Dimensions
matrix.rows(m1)               // 3
matrix.cols(m1)               // 3
matrix.shape(m1)              // [3, 3]
matrix.isSquare(m1)           // true

// Arithmetic
matrix.add(m1, m2)            // element-wise addition
matrix.sub(m1, m2)            // element-wise subtraction
matrix.mul(m1, m2)            // matrix multiplication
matrix.scale(m1, 2)           // scalar multiplication
matrix.hadamard(m1, m2)       // element-wise multiplication

// Transformations
matrix.transpose(m1)          // flip rows and columns
matrix.inverse(m1)            // matrix inverse (if exists)
matrix.trace(m1)              // sum of diagonal
matrix.determinant(m1)        // determinant
matrix.rank(m1)               // matrix rank
matrix.minor(m1, 0, 0)        // minor matrix

// Decompositions
matrix.lu(m1)                 // LU decomposition
matrix.qr(m1)                 // QR decomposition
matrix.eigenvalues(m1)        // eigenvalues
matrix.eigenvectors(m1)       // eigenvectors

// Predicates
matrix.isSymmetric(m1)
matrix.isOrthogonal(m1)
matrix.isSingular(m1)
matrix.isDiagonal(m1)

// Solving systems
matrix.solve(A, b)            // solve Ax = b
```

**Use Cases:**

- Machine learning (weights, transformations)
- Computer graphics (transforms, projections)
- Physics simulations
- Statistics (covariance matrices)
- Network analysis (adjacency matrices)

**Implementation Notes:**

- Store as nested lists internally with shape metadata
- Validate dimensions on operations
- Consider sparse matrix representation for large matrices
- Implement efficient algorithms (Strassen for multiplication)

---

### 4. Graph Type

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **High** |
| Impact     | **High** |

**Description:**
First-class graph data structure supporting both directed and undirected graphs with weighted edges.

**Proposed Syntax:**

```primal
// Creation
g1 = graph.new()                          // empty graph
g2 = graph.directed()                     // empty directed graph
g3 = graph.undirected()                   // empty undirected graph
g4 = graph.fromEdges([["a", "b"], ["b", "c"], ["c", "a"]])
g5 = graph.fromAdjacency({"a": ["b", "c"], "b": ["c"]})

// Modification (immutable - returns new graph)
g = graph.addVertex(g1, "a")
g = graph.addEdge(g, "a", "b")
g = graph.addEdge(g, "a", "b", 5)         // weighted edge
g = graph.removeVertex(g, "a")
g = graph.removeEdge(g, "a", "b")

// Queries
graph.vertices(g)                         // list of vertices
graph.edges(g)                            // list of edges
graph.neighbors(g, "a")                   // adjacent vertices
graph.inNeighbors(g, "a")                 // incoming (directed)
graph.outNeighbors(g, "a")                // outgoing (directed)
graph.degree(g, "a")                      // vertex degree
graph.inDegree(g, "a")
graph.outDegree(g, "a")
graph.hasVertex(g, "a")
graph.hasEdge(g, "a", "b")
graph.weight(g, "a", "b")                 // edge weight

// Properties
graph.order(g)                            // number of vertices
graph.size(g)                             // number of edges
graph.isDirected(g)
graph.isConnected(g)
graph.isAcyclic(g)
graph.isBipartite(g)
graph.isComplete(g)

// Traversals
graph.bfs(g, "a")                         // breadth-first from "a"
graph.dfs(g, "a")                         // depth-first from "a"
graph.topologicalSort(g)                  // for DAGs

// Algorithms
graph.shortestPath(g, "a", "b")           // Dijkstra
graph.allShortestPaths(g, "a")            // from one source
graph.minimumSpanningTree(g)              // Prim/Kruskal
graph.connectedComponents(g)
graph.stronglyConnected(g)                // for directed
graph.cycle(g)                            // find a cycle if exists
graph.path(g, "a", "b")                   // any path between

// Transformations
graph.reverse(g)                          // reverse edge directions
graph.subgraph(g, ["a", "b", "c"])        // induced subgraph
graph.complement(g)                       // graph complement
graph.union(g1, g2)
graph.intersection(g1, g2)
```

**Use Cases:**

- Social network analysis
- Route planning and navigation
- Dependency resolution
- Workflow modeling
- Game AI (pathfinding)
- Compiler optimizations (control flow graphs)

**Implementation Notes:**

- Store as adjacency list for sparse graphs
- Consider adjacency matrix for dense graphs
- Implement classic algorithms efficiently
- Support both value and reference vertices

---

### 5. Tree Type

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
First-class tree data structure with traversal and transformation operations. Trees are fundamental for hierarchical data.

**Proposed Syntax:**

```primal
// Creation
t1 = tree.leaf(5)                         // leaf node
t2 = tree.node(1, [tree.leaf(2), tree.leaf(3)])  // internal node
t3 = tree.fromNested([1, [2, [4, 5]], [3, [6, 7]]])  // from nested list
t4 = tree.binary(1, tree.leaf(2), tree.leaf(3))  // binary tree

// Access
tree.value(t2)                            // 1 (root value)
tree.children(t2)                         // [tree(2), tree(3)]
tree.child(t2, 0)                         // first child
tree.isLeaf(t1)                           // true
tree.isNode(t2)                           // true

// Properties
tree.size(t2)                             // number of nodes
tree.depth(t2)                            // maximum depth
tree.breadth(t2)                          // maximum width at any level
tree.leaves(t2)                           // list of leaf values

// Modification (immutable)
tree.setValue(t2, 10)                     // new tree with root = 10
tree.setChild(t2, 0, tree.leaf(20))       // replace child
tree.addChild(t2, tree.leaf(4))           // add child
tree.removeChild(t2, 0)                   // remove child
tree.prune(t2, pred)                      // remove subtrees matching pred

// Traversals (return lists of values)
tree.preorder(t2)                         // [1, 2, 3]
tree.postorder(t2)                        // [2, 3, 1]
tree.inorder(t2)                          // for binary trees
tree.levelorder(t2)                       // [1, 2, 3] (BFS)
tree.paths(t2)                            // all root-to-leaf paths

// Higher-order operations
tree.map(t2, fn)                          // apply fn to each value
tree.filter(t2, pred)                     // keep subtrees matching pred
tree.fold(t2, init, fn)                   // reduce tree to single value
tree.foldUp(t2, leafFn, nodeFn)           // bottom-up fold
tree.flatten(t2)                          // all values as flat list
tree.zip(t1, t2, fn)                      // combine two trees

// Search
tree.find(t2, pred)                       // first node matching pred
tree.findAll(t2, pred)                    // all matching nodes
tree.path(t2, pred)                       // path to first match
tree.contains(t2, value)                  // value exists in tree

// Transformations
tree.mirror(t2)                           // reverse children order
tree.balance(t2)                          // balance a binary tree
tree.rotate(t2, direction)                // AVL rotation
```

**Use Cases:**

- File system representation
- HTML/XML document trees
- Abstract syntax trees (ASTs)
- Decision trees
- Organizational hierarchies
- Game trees (minimax)

**Implementation Notes:**

- Generic tree with arbitrary branching factor
- Special support for binary trees
- Implement traversals as lazy sequences
- Consider zipper for efficient navigation

---

### 6. NonEmpty Collections

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Type-safe collections guaranteed to have at least one element. Eliminates null checks and "empty collection" errors at the type level.

**Proposed Syntax:**

```primal
// Creation
nel1 = nonempty.list(1, [2, 3, 4])        // head + tail
nel2 = nonempty.of(1, 2, 3)               // variadic
nel3 = nonempty.singleton(42)             // single element

// Conversion
nonempty.fromList([1, 2, 3])              // returns nonempty or error
nonempty.fromListSafe([1, 2, 3])          // returns nonempty or nothing
nonempty.toList(nel1)                     // back to regular list

// Safe operations (always succeed)
nonempty.head(nel1)                       // 1 (guaranteed to exist)
nonempty.last(nel1)                       // 4 (guaranteed to exist)
nonempty.tail(nel1)                       // [2, 3, 4] (may be empty)
nonempty.init(nel1)                       // [1, 2, 3] (may be empty)

// Preserving non-emptiness
nonempty.map(nel1, fn)                    // returns nonempty
nonempty.cons(0, nel1)                    // returns nonempty
nonempty.append(nel1, nel2)               // returns nonempty
nonempty.reverse(nel1)                    // returns nonempty

// May become empty (returns regular list)
nonempty.filter(nel1, pred)               // returns list
nonempty.drop(nel1, 2)                    // returns list

// Folding (no initial value needed)
nonempty.reduce(nel1, fn)                 // fold without init
nonempty.maximum(nel1)                    // guaranteed to exist
nonempty.minimum(nel1)                    // guaranteed to exist

// Properties
nonempty.length(nel1)                     // >= 1
nonempty.isSingleton(nel1)                // length == 1
```

**Use Cases:**

- Function that must return at least one result
- Configuration with required defaults
- Validation errors (at least one error)
- Selected items (at least one selected)

**Implementation Notes:**

- Store as (head, tail) pair internally
- Type system tracks non-emptiness
- Operations preserve or lose non-empty guarantee appropriately

---

### 7. Difference Lists

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
A list representation that supports O(1) append operations. Represented as a function from lists to lists, enabling efficient concatenation.

**Proposed Syntax:**

```primal
// Creation
dl1 = dlist.new()                         // empty
dl2 = dlist.singleton(1)                  // [1]
dl3 = dlist.fromList([1, 2, 3])           // convert from list

// Operations (all O(1))
dl4 = dlist.append(dl2, dl3)              // [1, 1, 2, 3]
dl5 = dlist.prepend(0, dl4)               // [0, 1, 1, 2, 3]
dl6 = dlist.concat([dl1, dl2, dl3])       // concatenate many

// Conversion (O(n))
dlist.toList(dl6)                         // materialize to regular list

// Use case: efficient string building
buildString(parts) =
  dlist.toList(
    list.reduce(parts, dlist.new(), (acc, p) ->
      dlist.append(acc, dlist.singleton(p))
    )
  )
```

**Use Cases:**

- Building large lists incrementally
- Logger that accumulates messages
- Parser combinators (accumulating results)
- Any left-fold that builds a list

**Implementation Notes:**

- Represent as `list -> list` function internally
- `append(dl1, dl2)` = `x -> dl1(dl2(x))`
- `toList(dl)` = `dl([])`
- Very simple implementation

---

### 8. Finger Trees

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
A general-purpose persistent data structure with O(1) access to both ends and O(log n) concatenation and random access.

**Proposed Syntax:**

```primal
// Creation
ft1 = finger.new()                        // empty
ft2 = finger.fromList([1, 2, 3, 4, 5])

// Access (O(1) at ends)
finger.first(ft2)                         // 1
finger.last(ft2)                          // 5

// Modification (O(1) amortized at ends)
finger.prepend(0, ft2)                    // [0, 1, 2, 3, 4, 5]
finger.append(ft2, 6)                     // [1, 2, 3, 4, 5, 6]
finger.tail(ft2)                          // [2, 3, 4, 5]
finger.init(ft2)                          // [1, 2, 3, 4]

// Concatenation (O(log n))
finger.concat(ft1, ft2)

// Random access (O(log n))
finger.at(ft2, 2)                         // 3
finger.set(ft2, 2, 30)                    // [1, 2, 30, 4, 5]

// Split (O(log n))
finger.splitAt(ft2, 2)                    // ([1, 2], [3, 4, 5])
finger.takeWhile(ft2, pred)
finger.dropWhile(ft2, pred)

// Properties
finger.length(ft2)
finger.isEmpty(ft2)
```

**Use Cases:**

- Double-ended queues (deques)
- Priority queues (with appropriate measure)
- Indexed sequences
- Text editors (rope-like functionality)

**Implementation Notes:**

- Complex implementation with 2-3 trees
- Parameterized by monoid for measurements
- Worth the complexity for specific use cases

---

### 9. Tries / Prefix Trees

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **Medium** |

**Description:**
Tree structure for efficient string/sequence lookup with prefix-based operations.

**Proposed Syntax:**

```primal
// Creation
t1 = trie.new()
t2 = trie.fromList(["cat", "car", "card", "care", "careful"])
t3 = trie.fromMap({"cat": 1, "car": 2, "card": 3})

// Insertion/Deletion
trie.insert(t1, "hello")                  // set (no value)
trie.insert(t1, "hello", 42)              // map (with value)
trie.remove(t2, "cat")

// Lookup
trie.contains(t2, "car")                  // true
trie.get(t3, "cat")                       // 1
trie.startsWith(t2, "ca")                 // true

// Prefix operations
trie.withPrefix(t2, "car")                // ["car", "card", "care", "careful"]
trie.longestPrefix(t2, "careful")         // "careful"
trie.commonPrefix(t2)                     // "ca" (common to all)

// Autocomplete
trie.complete(t2, "car")                  // ["", "d", "e", "eful"]
trie.suggestions(t2, "car", 3)            // top 3 completions

// Traversal
trie.keys(t2)                             // all keys
trie.values(t3)                           // all values (for map trie)
trie.entries(t3)                          // key-value pairs

// Properties
trie.size(t2)                             // number of entries
trie.isEmpty(t2)
```

**Use Cases:**

- Autocomplete/typeahead
- Spell checkers
- IP routing tables
- Dictionary implementations
- Command-line tab completion

**Implementation Notes:**

- Each node has map of character -> child
- Terminal nodes marked with flag/value
- Consider compressed tries (radix trees) for efficiency

---

### 10. Persistent Vectors

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Clojure-style persistent vectors with efficient random access and updates through structural sharing.

**Proposed Syntax:**

```primal
// Creation
pv1 = pvec.new()
pv2 = pvec.fromList([1, 2, 3, 4, 5])
pv3 = pvec.range(0, 1000000)              // efficient large vector

// Access (O(log32 n) ≈ O(1) for practical sizes)
pvec.at(pv2, 2)                           // 3
pvec.first(pv2)                           // 1
pvec.last(pv2)                            // 5

// Modification (O(log32 n) with structural sharing)
pvec.set(pv2, 2, 30)                      // [1, 2, 30, 4, 5]
pvec.append(pv2, 6)                       // [1, 2, 3, 4, 5, 6]
pvec.pop(pv2)                             // [1, 2, 3, 4]

// Slicing
pvec.subvec(pv2, 1, 4)                    // [2, 3, 4]
pvec.take(pv2, 3)                         // [1, 2, 3]
pvec.drop(pv2, 2)                         // [3, 4, 5]

// Transformation
pvec.map(pv2, fn)
pvec.filter(pv2, pred)
pvec.reduce(pv2, init, fn)

// Properties
pvec.length(pv2)
pvec.isEmpty(pv2)
```

**Use Cases:**

- Large immutable sequences
- Undo/redo with minimal memory
- Concurrent data sharing
- Functional data pipelines

**Implementation Notes:**

- 32-way branching trie structure
- Path copying for updates
- Tail optimization for appends
- Very efficient for practical sizes

---

## Functional Programming Patterns

### 11. Lenses / Optics

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **High** |
| Impact     | **High** |

**Description:**
Composable getters and setters for deeply nested immutable data structures. Lenses solve the "nested update problem" in functional programming.

**Proposed Syntax:**

```primal
// Given nested data
person = {
  "name": "Alice",
  "address": {
    "street": "123 Main St",
    "city": "Boston",
    "zip": {"code": "02101", "plus4": "1234"}
  },
  "contacts": [
    {"type": "email", "value": "alice@example.com"},
    {"type": "phone", "value": "555-1234"}
  ]
}

// Lens creation
nameLens = lens.key("name")
addressLens = lens.key("address")
cityLens = lens.key("city")
zipLens = lens.key("zip")
codeLens = lens.key("code")

// Lens composition (deeply nested access)
zipCodeLens = lens.compose(addressLens, zipLens, codeLens)

// Get (view through lens)
lens.get(nameLens, person)                // "Alice"
lens.get(zipCodeLens, person)             // "02101"

// Set (immutable update through lens)
lens.set(nameLens, person, "Bob")         // {name: "Bob", ...}
lens.set(zipCodeLens, person, "02102")    // deeply nested update

// Modify (update with function)
lens.over(nameLens, person, str.uppercase)  // {name: "ALICE", ...}
lens.over(zipCodeLens, person, (z) -> z + "-0000")

// List lenses
firstContact = lens.index(0)
contactsLens = lens.key("contacts")
firstContactLens = lens.compose(contactsLens, firstContact)

// Traversals (focus on multiple elements)
allContacts = lens.each(contactsLens)
lens.getAll(allContacts, person)          // all contact maps
lens.overAll(allContacts, person, fn)     // modify all

// Prisms (for sum types / optional values)
maybeName = prism.key("nickname")         // may not exist
prism.preview(maybeName, person)          // nothing (doesn't exist)
prism.set(maybeName, person, "Ali")       // adds the key

// Isos (isomorphisms)
celsiusFahrenheit = iso.new(
  (c) -> c * 9/5 + 32,                    // to Fahrenheit
  (f) -> (f - 32) * 5/9                   // to Celsius
)
iso.forward(celsiusFahrenheit, 100)       // 212
iso.backward(celsiusFahrenheit, 32)       // 0
```

**Use Cases:**

- Updating deeply nested configuration
- State management in applications
- JSON/data transformation pipelines
- Working with immutable UI state

**Implementation Notes:**

- Lens = pair of getter and setter functions
- Composition is function composition
- Prisms handle optional/sum types
- Consider van Laarhoven representation for better composition

---

### 12. Transducers

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Composable algorithmic transformations that are independent of the input/output source. Unlike chained map/filter, transducers don't create intermediate collections.

**Proposed Syntax:**

```primal
// Individual transducers
mapT = transducer.map((x) -> x * 2)
filterT = transducer.filter((x) -> x > 5)
takeT = transducer.take(10)
dropT = transducer.drop(5)
flatMapT = transducer.flatMap((x) -> [x, x])
distinctT = transducer.distinct()
partitionT = transducer.partition(3)

// Composition (no intermediate collections!)
pipeline = transducer.compose(
  transducer.filter((x) -> num.isEven(x)),
  transducer.map((x) -> x * x),
  transducer.take(5)
)

// Apply to different collection types
transducer.into([], pipeline, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
// Result: [4, 16, 36, 64, 100]

transducer.into(set.new([]), pipeline, myList)   // into a set
transducer.into("", stringPipeline, charList)     // into a string

// Transduce with custom reducing function
transducer.transduce(pipeline, +, 0, numbers)     // sum after transform

// Early termination
transducer.compose(
  transducer.map(expensiveComputation),
  transducer.take(3)                              // stops after 3
)

// Stateful transducers
transducer.dedupe()                               // remove consecutive dupes
transducer.interpose(separator)                   // insert between elements
transducer.mapIndexed((i, x) -> [i, x])          // with index
```

**Use Cases:**

- Processing large data sets efficiently
- Building reusable transformation pipelines
- Stream processing
- Avoiding memory overhead of intermediate collections

**Implementation Notes:**

- Transducer = `(reducer -> reducer)` function
- Composition is right-to-left function composition
- Must handle reduced (early termination) properly
- Can be applied to any foldable structure

---

### 13. Trampolining

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Built-in support for converting recursive functions to iterative execution, preventing stack overflow for deep recursion.

**Proposed Syntax:**

```primal
// Without trampolining - stack overflow for large n
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)

// With trampolining - safe for any n
factorialT(n, acc) =
  if (n <= 1)
    trampoline.done(acc)
  else
    trampoline.bounce(() -> factorialT(n - 1, n * acc))

factorial(n) = trampoline.run(factorialT(n, 1))

// Mutual recursion with trampolining
isEven(n) =
  if (n == 0) trampoline.done(true)
  else trampoline.bounce(() -> isOdd(n - 1))

isOdd(n) =
  if (n == 0) trampoline.done(false)
  else trampoline.bounce(() -> isEven(n - 1))

checkEven(n) = trampoline.run(isEven(num.abs(n)))

// Automatic trampolining (syntax sugar)
@trampolined
sumList(lst, acc) =
  if (list.isEmpty(lst)) acc
  else sumList(list.rest(lst), acc + list.first(lst))
```

**Use Cases:**

- Deep recursive algorithms
- Tree traversals on large trees
- Parsing deeply nested structures
- Any recursive algorithm that might overflow

**Implementation Notes:**

- Trampoline = loop that handles `Done` or `Bounce` values
- Simple to implement: `Bounce` wraps thunk, `Done` wraps result
- Could integrate with tail-call optimization detection

---

### 14. Codata / Corecursion

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **Medium** |

**Description:**
Support for infinite data structures defined by how they produce elements (corecursion) rather than how they're consumed (recursion). Already partially supported via laziness, but explicit codata would be clearer.

**Proposed Syntax:**

```primal
// Infinite streams (codata)
naturals = codata.unfold(0, (n) -> [n, n + 1])
// Conceptually: [0, 1, 2, 3, 4, ...]

// Fibonacci sequence
fibs = codata.unfold([0, 1], ([a, b]) -> [a, [b, a + b]])
// Conceptually: [0, 1, 1, 2, 3, 5, 8, ...]

// Repeat a value infinitely
ones = codata.repeat(1)
// [1, 1, 1, 1, ...]

// Cycle through values
cycle123 = codata.cycle([1, 2, 3])
// [1, 2, 3, 1, 2, 3, ...]

// Iterate a function
powersOf2 = codata.iterate(1, (x) -> x * 2)
// [1, 2, 4, 8, 16, ...]

// Take finite prefix (force evaluation)
codata.take(10, naturals)                 // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
codata.take(10, fibs)                     // [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

// Transformations (remain lazy)
evens = codata.filter(naturals, num.isEven)
squares = codata.map(naturals, (n) -> n * n)

// Combining infinite streams
codata.zip(naturals, fibs, (a, b) -> [a, b])
codata.interleave(ones, naturals)         // [1, 0, 1, 1, 1, 2, ...]

// Finding in infinite streams
codata.find(naturals, (n) -> n > 100)     // 101
codata.takeWhile(naturals, (n) -> n < 10) // [0..9]
codata.dropWhile(naturals, (n) -> n < 10) // [10, 11, 12, ...]

// Anamorphisms (unfold)
codata.ana(seed, predicate, mapper, next)
```

**Use Cases:**

- Mathematical sequences
- Event streams
- Lazy I/O
- Simulation ticks
- Infinite game worlds

**Implementation Notes:**

- Represent as thunk that produces (head, tail-thunk)
- Must prevent accidental forcing of infinite structures
- Clear distinction from finite lists

---

### 15. First-Class Patterns

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
Patterns as values that can be composed, stored, and passed to functions. Enables building complex patterns from simple ones.

**Proposed Syntax:**

```primal
// Basic patterns
anyP = pattern.any()                      // matches anything
litP = pattern.lit(42)                    // matches exactly 42
varP = pattern.var("x")                   // binds to "x"

// Type patterns
numP = pattern.type("number")
strP = pattern.type("string")
listP = pattern.type("list")

// Compound patterns
pairP = pattern.list([pattern.var("a"), pattern.var("b")])
consP = pattern.cons(pattern.var("head"), pattern.var("tail"))

// Pattern combinators
orP = pattern.or(numP, strP)              // matches number OR string
andP = pattern.and(numP, pattern.guard((n) -> n > 0))  // positive number
notP = pattern.not(litP)                  // anything except 42

// Predicate patterns
evenP = pattern.where(numP, num.isEven)
nonEmptyP = pattern.where(listP, list.isNotEmpty)

// Using patterns
pattern.match(evenP, 42)                  // true
pattern.match(evenP, 41)                  // false

pattern.extract(pairP, [1, 2])            // {"a": 1, "b": 2}

// Pattern matching expression using first-class patterns
pattern.case(value, [
  [pairP, (bindings) -> bindings.a + bindings.b],
  [litP, (bindings) -> "exact match"],
  [anyP, (bindings) -> "default"]
])
```

**Use Cases:**

- Building domain-specific pattern languages
- Validation frameworks
- Parsing combinators
- Query expressions

**Implementation Notes:**

- Pattern = object with match and extract methods
- Composition creates new pattern objects
- Integrate with pattern matching syntax

---

### 16. Active Patterns

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
User-defined pattern decompositions that run arbitrary code during pattern matching. Inspired by F#'s active patterns.

**Proposed Syntax:**

```primal
// Single-case active pattern (total)
@pattern Even(n) = if (num.isEven(n)) n / 2 else fail
@pattern Odd(n) = if (num.isOdd(n)) (n - 1) / 2 else fail

// Usage in pattern matching
classify(n) = match n with
  | Even(half) -> "even, half is " + to.string(half)
  | Odd(half) -> "odd, half of predecessor is " + to.string(half)

// Multi-case active pattern (complete)
@pattern Sign(n) =
  | Positive when n > 0
  | Zero when n == 0
  | Negative when n < 0

describe(n) = match n with
  | Positive -> "positive"
  | Zero -> "zero"
  | Negative -> "negative"

// Partial active pattern (may fail)
@pattern Integer(s) = try(to.integer(s), fail)

parseNum(s) = match s with
  | Integer(n) -> "got integer: " + to.string(n)
  | _ -> "not an integer"

// Parameterized active pattern
@pattern DivisibleBy(d)(n) = if (n % d == 0) n / d else fail

fizzbuzz(n) = match n with
  | DivisibleBy(15)(x) -> "FizzBuzz"
  | DivisibleBy(3)(x) -> "Fizz"
  | DivisibleBy(5)(x) -> "Buzz"
  | _ -> to.string(n)

// Regex active pattern
@pattern Regex(pat)(s) = str.match(s, pat)

parseEmail(s) = match s with
  | Regex("(.+)@(.+)\\.(.+)")(user, domain, tld) ->
      {"user": user, "domain": domain, "tld": tld}
  | _ -> "invalid email"
```

**Use Cases:**

- Parsing and validation
- Domain modeling
- Complex conditional logic
- Data extraction

**Implementation Notes:**

- Active pattern = function returning match result or failure
- Integrate with pattern matching desugaring
- Consider partial vs total patterns

---

### 17. Monoid / Semigroup Operations

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Built-in support for algebraic structures with associative operations. Enables generic folding and combining.

**Proposed Syntax:**

```primal
// Built-in monoid instances
monoid.sum                                // numbers with +, identity 0
monoid.product                            // numbers with *, identity 1
monoid.concat                             // lists with ++, identity []
monoid.all                                // booleans with &&, identity true
monoid.any                                // booleans with ||, identity false
monoid.min                                // numbers with min, identity infinity
monoid.max                                // numbers with max, identity -infinity

// Using monoids generically
monoid.fold(monoid.sum, [1, 2, 3, 4, 5])  // 15
monoid.fold(monoid.product, [1, 2, 3, 4]) // 24
monoid.fold(monoid.all, [true, true, false]) // false

// Combining with monoid
monoid.combine(monoid.concat, [1, 2], [3, 4])  // [1, 2, 3, 4]

// Custom monoids
counterMonoid = monoid.new(
  0,                                      // identity
  (a, b) -> a + b                         // combine
)

// First/Last monoids (for optional values)
monoid.first                              // keeps first non-empty
monoid.last                               // keeps last non-empty

// Endo monoid (function composition)
monoid.endo                               // functions with compose, identity id

// Dual monoid (reverses order)
monoid.dual(monoid.concat)                // prepend instead of append

// Semigroup (no identity required)
semigroup.min
semigroup.max
semigroup.first
semigroup.last

// NonEmpty uses semigroup (guaranteed at least one element)
semigroup.fold(semigroup.max, nonempty.of(1, 5, 3, 2))  // 5
```

**Use Cases:**

- Generic aggregation
- Parallel-safe combining
- Configuration merging
- Accumulating results

**Implementation Notes:**

- Monoid = {identity, combine} where combine is associative
- Enables parallelization (associativity)
- Many built-in types have natural monoid instances

---

### 18. Functors and Applicatives

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **Medium** |

**Description:**
Explicit functor and applicative interfaces for mapping and combining computations in context.

**Proposed Syntax:**

```primal
// Functor: map over structure
functor.map(list.functor, [1, 2, 3], (x) -> x * 2)     // [2, 4, 6]
functor.map(maybe.functor, some(5), (x) -> x * 2)      // some(10)
functor.map(maybe.functor, nothing, (x) -> x * 2)      // nothing

// Applicative: apply functions in context
applicative.pure(list.applicative, 5)                  // [5]
applicative.pure(maybe.applicative, 5)                 // some(5)

// Apply function in context to value in context
applicative.ap(
  list.applicative,
  [(x) -> x * 2, (x) -> x + 1],           // functions in list
  [1, 2, 3]                               // values in list
)
// Result: [2, 4, 6, 2, 3, 4]

// lift2: apply 2-arg function to two contexts
applicative.lift2(
  maybe.applicative,
  (a, b) -> a + b,
  some(3),
  some(4)
)
// Result: some(7)

// Sequence: turn list of contexts into context of list
applicative.sequence(maybe.applicative, [some(1), some(2), some(3)])
// Result: some([1, 2, 3])

applicative.sequence(maybe.applicative, [some(1), nothing, some(3)])
// Result: nothing

// Traverse: map and sequence combined
applicative.traverse(maybe.applicative, [1, 2, 3], safeDivide(10))
// Result: some([10, 5, 3]) or nothing if any division fails

// Useful for validation
validateAll(inputs) = applicative.traverse(
  validation.applicative,
  inputs,
  validateSingle
)
```

**Use Cases:**

- Uniform interface for mapping
- Combining optional values
- Parallel validation
- Effectful traversals

**Implementation Notes:**

- Functor laws: identity, composition
- Applicative laws: identity, composition, homomorphism, interchange
- Dictionary-passing style or type classes

---

## Effects & Control Flow

### 19. Algebraic Effects / Effect Handlers

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **High**   |

**Description:**
A modern approach to managing side effects that separates effect declaration from effect handling. More flexible than monads.

**Proposed Syntax:**

```primal
// Declare effects
effect Console {
  read() -> String
  write(msg: String) -> Unit
}

effect State(s) {
  get() -> s
  put(value: s) -> Unit
}

effect Exception(e) {
  throw(error: e) -> Nothing
}

// Use effects in functions
greet() = do {
  Console.write("What's your name? ")
  name <- Console.read()
  Console.write("Hello, " + name + "!")
}

counter() = do {
  current <- State.get()
  State.put(current + 1)
  return current
}

// Handle effects
handler ConsoleHandler {
  return(x) -> x
  read() -> resume("Alice")               // mock input
  write(msg) -> do { log(msg); resume(()) }
}

// Run with handler
handle(greet(), ConsoleHandler)

// Compose handlers
handle(
  handle(program(), StateHandler(0)),
  ConsoleHandler
)

// Built-in effect: nondeterminism
effect Choice {
  choose(options: List) -> a
  fail() -> Nothing
}

// Example: parsing with backtracking
parseDigit() = do {
  c <- Choice.choose(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'])
  return to.integer(c)
}

handler ListHandler {
  return(x) -> [x]
  choose(opts) -> list.flatMap(opts, (o) -> resume(o))
  fail() -> []
}
```

**Use Cases:**

- Controlled side effects
- Dependency injection
- Testing (mock effects)
- Backtracking/search
- Async/concurrent programming

**Implementation Notes:**

- Requires delimited continuations internally
- Effect rows for tracking which effects are used
- Significant compiler/runtime changes

---

### 20. Delimited Continuations

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
First-class control flow with `shift` and `reset` operators. Enables implementing complex control patterns.

**Proposed Syntax:**

```primal
// reset: delimits the continuation
// shift: captures the continuation up to enclosing reset

// Basic example
example1() = reset(
  1 + shift((k) -> k(k(2)))               // k = (x) -> 1 + x
)
// Result: 1 + (1 + 2) = 4

// Early return
findFirst(lst, pred) = reset(
  list.map(lst, (x) ->
    if (pred(x)) shift((k) -> x) else x
  )
)

// Generators using continuations
makeGenerator(body) = do {
  state <- ref(nothing)

  yield(value) = shift((k) -> do {
    ref.set(state, some(k))
    value
  })

  next() = match ref.get(state) with
    | nothing -> body()
    | some(k) -> k(())

  return {"next": next}
}

// Example generator
counter() = makeGenerator(() -> do {
  yield(1)
  yield(2)
  yield(3)
})

// Coroutines
coroutine(body) = reset(body())

suspend() = shift((k) -> {"resume": k, "status": "suspended"})

// Backtracking
amb(choices) = shift((k) ->
  list.flatMap(choices, k)
)

// Example: pythagorean triples
triples(n) = reset(do {
  a <- amb(list.range(1, n))
  b <- amb(list.range(a, n))
  c <- amb(list.range(b, n))
  if (a*a + b*b == c*c)
    [[a, b, c]]
  else
    []
})
```

**Use Cases:**

- Implementing generators
- Coroutines
- Backtracking search
- Exception handling
- Async/await patterns

**Implementation Notes:**

- Requires CPS transformation or stack manipulation
- Performance considerations
- Careful interaction with other features

---

### 21. Validation Type

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Like Result/Either but accumulates all errors instead of short-circuiting on the first one. Essential for form validation and data processing.

**Proposed Syntax:**

```primal
// Creation
valid1 = validation.success(42)
valid2 = validation.failure("must be positive")
valid3 = validation.failure(["error 1", "error 2"])

// Validation functions
validatePositive(n) =
  if (n > 0) validation.success(n)
  else validation.failure("must be positive")

validateEven(n) =
  if (num.isEven(n)) validation.success(n)
  else validation.failure("must be even")

validateMax(max)(n) =
  if (n <= max) validation.success(n)
  else validation.failure("must be <= " + to.string(max))

// Combining validations (accumulates ALL errors)
validateNumber(n) = validation.combine([
  validatePositive(n),
  validateEven(n),
  validateMax(100)(n)
])

validateNumber(-3)   // failure(["must be positive", "must be even"])
validateNumber(4)    // success(4)
validateNumber(101)  // failure(["must be even", "must be <= 100"])

// Applicative combination
validatePerson(name, age, email) = validation.map3(
  validateName(name),
  validateAge(age),
  validateEmail(email),
  (n, a, e) -> {"name": n, "age": a, "email": e}
)

// All errors collected, not just the first
validatePerson("", -5, "invalid")
// failure(["name required", "age must be positive", "invalid email format"])

// Converting from Result (loses accumulation)
validation.fromResult(result)
validation.toResult(validation)  // takes first error

// Partition successes and failures
validation.partition([valid1, valid2, valid3])
// {"successes": [...], "failures": [...]}

// Ensure: add validation to existing value
validation.ensure(
  someValue,
  pred,
  "error if pred fails"
)

// Conditional validation
validation.when(condition, validator)
validation.unless(condition, validator)

// Nested validation
validateAddress(addr) = validation.combine([
  validation.field("street", validateNonEmpty, addr),
  validation.field("city", validateNonEmpty, addr),
  validation.field("zip", validateZipCode, addr)
])
```

**Use Cases:**

- Form validation (show all errors at once)
- Data import (collect all parsing errors)
- Configuration validation
- API request validation

**Implementation Notes:**

- Store errors as list (semigroup for combining)
- Applicative instance accumulates; Monad would short-circuit
- Integrate with Result type

---

### 22. Implicit Parameters

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **Medium** |

**Description:**
Parameters that are automatically passed through the call chain without explicit threading. Useful for configuration, logging, and dependency injection.

**Proposed Syntax:**

```primal
// Declare implicit parameter
implicit config: Config
implicit logger: Logger

// Function using implicit
processData(data) = do {
  // config is available implicitly
  threshold <- config.threshold
  logger.info("Processing with threshold: " + to.string(threshold))

  list.filter(data, (x) -> x > threshold)
}

// Nested call - implicit flows through
analyze(input) = do {
  processed <- processData(input)
  summarize(processed)                    // also uses implicit config
}

// Providing implicit at call site
withImplicit(
  {config: myConfig, logger: myLogger},
  () -> analyze(myData)
)

// Or using 'given' syntax
given config = loadConfig()
given logger = createLogger()
result = analyze(myData)

// Default implicits
implicit config: Config = defaultConfig

// Implicit resolution: local > enclosing > default

// Implicit functions (function that uses implicits)
sortByConfig(lst)(implicit ordering: Ord) =
  list.sort(lst, ordering.compare)

// Summoning implicit
getImplicit(config)                       // get current implicit value

// Conditional implicit
whenImplicit(logger, (l) -> l.debug("..."))
```

**Use Cases:**

- Configuration threading
- Logging context
- Transaction context
- Locale/i18n
- Dependency injection

**Implementation Notes:**

- Scope-based resolution
- Compile-time or runtime resolution
- Clear rules for ambiguity

---

### 23. Async / Promises

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Asynchronous computation support with promises/futures. While Primal is single-threaded, async enables non-blocking I/O.

**Proposed Syntax:**

```primal
// Creating promises
p1 = async.resolve(42)                    // immediately resolved
p2 = async.reject("error")                // immediately rejected
p3 = async.delay(1000, 42)                // resolves after 1 second

// Async function declaration
fetchUser(id) = async do {
  response <- http.get("/users/" + to.string(id))
  json.decode(response.body)
}

// Awaiting (inside async context)
processUser(id) = async do {
  user <- await fetchUser(id)
  posts <- await fetchPosts(user.id)
  return {"user": user, "posts": posts}
}

// Chaining
fetchUser(1)
  |> async.then((user) -> fetchPosts(user.id))
  |> async.then((posts) -> list.length(posts))
  |> async.catch((err) -> 0)

// Parallel execution
async.all([fetchUser(1), fetchUser(2), fetchUser(3)])
// Resolves when ALL complete, with list of results

async.race([fetchA(), fetchB()])
// Resolves when FIRST completes

async.any([fetchA(), fetchB()])
// Resolves when first SUCCESS (ignores failures until all fail)

async.allSettled([p1, p2, p3])
// Always resolves, with status of each

// Error handling
async.catch(promise, (err) -> defaultValue)
async.finally(promise, () -> cleanup())

// Timeout
async.timeout(5000, slowOperation())

// Retry
async.retry(3, () -> unreliableOperation())
async.retryWithBackoff(3, 1000, () -> operation())

// Converting callback to promise
async.fromCallback((resolve, reject) ->
  legacyApi(data, resolve, reject)
)

// Running async in sync context (blocks - use sparingly)
async.runSync(promise)
```

**Use Cases:**

- HTTP requests
- File I/O (non-blocking)
- Timers and delays
- Parallel data fetching
- Event handling

**Implementation Notes:**

- Event loop integration
- Promise/A+ compatible semantics
- Clear async boundary

---

### 24. Streams / Observables

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
Reactive streams for handling sequences of asynchronous events over time.

**Proposed Syntax:**

```primal
// Creating streams
s1 = stream.of(1, 2, 3)                   // finite stream
s2 = stream.fromList([1, 2, 3])
s3 = stream.interval(1000)                // tick every second
s4 = stream.fromEvent(button, "click")

// Transformations
stream.map(s1, (x) -> x * 2)
stream.filter(s1, (x) -> x > 1)
stream.flatMap(s1, (x) -> stream.of(x, x))
stream.scan(s1, 0, (acc, x) -> acc + x)   // running total

// Combining streams
stream.merge(s1, s2)                      // interleave
stream.concat(s1, s2)                     // sequential
stream.zip(s1, s2, (a, b) -> [a, b])
stream.combineLatest(s1, s2, (a, b) -> a + b)

// Filtering by time
stream.debounce(s1, 300)                  // wait for pause
stream.throttle(s1, 1000)                 // max once per second
stream.sample(s1, 500)                    // take latest every 500ms

// Buffering
stream.buffer(s1, 3)                      // groups of 3
stream.bufferTime(s1, 1000)               // collect for 1 second
stream.window(s1, 5)                      // sliding window

// Control
stream.take(s1, 5)                        // first 5
stream.takeUntil(s1, stopSignal)
stream.takeWhile(s1, pred)
stream.skip(s1, 2)
stream.distinct(s1)
stream.distinctUntilChanged(s1)

// Error handling
stream.catch(s1, (err) -> stream.of(default))
stream.retry(s1, 3)

// Subscribing
stream.subscribe(s1, {
  "onNext": (x) -> console.writeLn(x),
  "onError": (e) -> console.writeLn("Error: " + e),
  "onComplete": () -> console.writeLn("Done")
})

// Subjects (both source and sink)
subj = stream.subject()
stream.next(subj, value)
stream.complete(subj)
```

**Use Cases:**

- User input handling
- Real-time data feeds
- Event-driven architectures
- Animation
- WebSocket messages

**Implementation Notes:**

- Push-based (vs pull-based iterators)
- Backpressure handling
- Memory management for subscriptions

---

## Type System Enhancements

### 25. Units of Measure

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
Track physical units at the type level, preventing unit mismatch errors at compile time.

**Proposed Syntax:**

```primal
// Define base units
unit Meter
unit Second
unit Kilogram
unit Ampere

// Define derived units
unit Newton = Kilogram * Meter / Second^2
unit Joule = Newton * Meter
unit Watt = Joule / Second
unit Hertz = 1 / Second

// Literal syntax
distance = 100<Meter>
time = 9.58<Second>
mass = 75<Kilogram>

// Arithmetic preserves/combines units
speed = distance / time                   // type: Number<Meter/Second>
acceleration = speed / time               // type: Number<Meter/Second^2>
force = mass * acceleration               // type: Number<Newton>

// Unit conversion
unit Mile = 1609.34 * Meter
unit Foot = 0.3048 * Meter
unit Inch = Foot / 12

distanceMiles = unit.convert(distance, Mile)  // ~0.062 miles

// Dimensionless quantities
ratio = 5<Meter> / 10<Meter>              // type: Number (dimensionless)

// Unit mismatch = compile error
bad = 5<Meter> + 3<Second>                // ERROR: incompatible units

// Temperature (special handling for offset units)
unit Celsius offset 273.15 from Kelvin
unit Fahrenheit offset 459.67 scale 5/9 from Kelvin

temp1 = 20<Celsius>
temp2 = unit.convert(temp1, Fahrenheit)   // 68°F

// Custom unit systems
unit USD
unit EUR
exchangeRate = 0.92<EUR/USD>
euros = 100<USD> * exchangeRate           // 92<EUR>

// Dimensionless constants
pi = 3.14159<1>                           // explicitly dimensionless
```

**Use Cases:**

- Physics simulations
- Engineering calculations
- Financial applications (currency)
- Scientific computing
- Preventing Mars Climate Orbiter disasters

**Implementation Notes:**

- Units as type-level tags
- Compile-time unit checking
- SI base units + derived units
- Conversion factors

---

### 26. Nominal Newtypes

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Create distinct types from existing types with zero runtime overhead. Prevents mixing up semantically different values.

**Proposed Syntax:**

```primal
// Declare newtypes
newtype UserId = Number
newtype ProductId = Number
newtype Email = String
newtype Password = String
newtype Cents = Number

// Construction
userId = UserId(42)
productId = ProductId(42)

// These are different types despite same underlying value!
userId == productId                       // TYPE ERROR

// Unwrap to get underlying value
UserId.unwrap(userId)                     // 42
userId.unwrap                             // 42 (method syntax)

// Newtypes don't inherit operations by default
userId + 1                                // TYPE ERROR

// Explicitly derive operations
newtype Cents = Number deriving (Eq, Ord, Add, Show)

price1 = Cents(500)
price2 = Cents(300)
total = price1 + price2                   // Cents(800) - OK!

// Newtype with validation
newtype Email = String where {
  validate(s) = str.contains(s, "@") & str.contains(s, ".")
}

Email("valid@example.com")                // OK
Email("invalid")                          // ERROR: validation failed

// Newtype with smart constructor
newtype PositiveInt = Number {
  new(n) = if (n > 0) some(PositiveInt(n)) else nothing
}

PositiveInt.new(5)                        // some(PositiveInt(5))
PositiveInt.new(-3)                       // nothing

// Coerce between newtypes with same underlying type (explicit)
coerce(userId, ProductId)                 // only if explicitly allowed

// Newtype over complex type
newtype PersonMap = Map<String, Person>
newtype SortedList<a> = List<a>
```

**Use Cases:**

- Preventing ID mixups (user ID vs product ID)
- Sensitive data (password vs regular string)
- Domain modeling
- Type-safe wrappers

**Implementation Notes:**

- Zero runtime overhead (same representation)
- Distinct at type level only
- Controlled coercion

---

### 27. Row Polymorphism

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **High**   |

**Description:**
Extensible records where functions can work on any record that has at least the required fields.

**Proposed Syntax:**

```primal
// Record type with open row
type HasName = {name: String, ...rest}
type HasAge = {age: Number, ...rest}
type HasNameAndAge = {name: String, age: Number, ...rest}

// Function works on any record with 'name' field
greet(person: HasName) = "Hello, " + person.name

// Works with different record shapes
greet({name: "Alice"})                    // OK
greet({name: "Bob", age: 30})             // OK
greet({name: "Carol", email: "c@x.com"})  // OK

// Combining row constraints
introduce(p: HasNameAndAge) =
  p.name + " is " + to.string(p.age) + " years old"

// Row extension
addEmail(person: {name: String, ...r}, email) =
  {...person, email: email}
// Return type: {name: String, email: String, ...r}

// Row restriction (removing fields)
removeAge(person: {age: Number, ...r}) =
  person without age
// Return type: {...r}

// Polymorphic record update
setName(person: {name: String, ...r}, newName) =
  {...person, name: newName}
// Works on any record with name field, preserves other fields

// Closed vs open records
type Person = {name: String, age: Number}        // closed (exact)
type HasPerson = {name: String, age: Number, ...} // open (at least)

// Variant types with row polymorphism
type Result<e, a> = <Ok: a, Err: e>
type ExtendedResult<e, a> = <Ok: a, Err: e, Pending: Unit, ...>

// Pattern matching with row types
handleResult(r: <Ok: a, Err: e, ...rest>) = match r with
  | Ok(x) -> "success: " + to.string(x)
  | Err(e) -> "error: " + to.string(e)
  | other -> "other case"
```

**Use Cases:**

- Flexible record manipulation
- Extensible APIs
- Plugin systems
- Gradual typing

**Implementation Notes:**

- Row variables in type system
- Unification with row constraints
- Significant type system changes

---

### 28. Linear / Affine Types

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Low**    |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
Types that must be used exactly once (linear) or at most once (affine). Enables safe resource management.

**Proposed Syntax:**

```primal
// Linear type: must use exactly once
linear type FileHandle

openFile(path: String) -> FileHandle
closeFile(handle: FileHandle) -> Unit     // consumes handle
readFile(handle: FileHandle) -> (String, FileHandle)  // returns new handle

// Usage
processFile(path) = do {
  handle <- openFile(path)
  (content, handle') <- readFile(handle)  // must use returned handle
  closeFile(handle')                      // must close
  content
}

// Error: using handle twice
bad1(path) = do {
  handle <- openFile(path)
  readFile(handle)
  readFile(handle)                        // ERROR: handle already used
}

// Error: not using handle
bad2(path) = do {
  handle <- openFile(path)                // ERROR: handle not consumed
  "done"
}

// Affine type: use at most once
affine type Connection

// Can be dropped (not used), but not duplicated
maybeUse(conn: Connection, needed: Boolean) =
  if (needed)
    query(conn, "SELECT 1")
  else
    "skipped"                             // OK: conn dropped

// Borrowing: temporary non-consuming access
readOnly(handle: &FileHandle) -> String   // borrow, don't consume

// Unrestricted (normal) types
unrestricted type Config                  // can use any number of times

// Multiplicity annotations
type Resource<m: Multiplicity, a> = ...
linear = One
affine = ZeroOrOne
unrestricted = Many
```

**Use Cases:**

- File handle safety
- Database connections
- Memory management
- Protocol state machines
- Preventing resource leaks

**Implementation Notes:**

- Significant type system addition
- Usage tracking in type checker
- May conflict with Primal's simplicity goal

---

### 29. Phantom Types

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Type parameters that don't appear in the runtime representation but provide compile-time safety.

**Proposed Syntax:**

```primal
// Phantom type parameter 'state' not used in data
type Door<state> = {id: Number}

// State markers (empty types)
type Open
type Closed
type Locked

// Operations with phantom type constraints
openDoor(door: Door<Closed>) -> Door<Open>
closeDoor(door: Door<Open>) -> Door<Closed>
lockDoor(door: Door<Closed>) -> Door<Locked>
unlockDoor(door: Door<Locked>) -> Door<Closed>

// Usage
workflow() = do {
  door <- Door<Closed>({id: 1})
  opened <- openDoor(door)
  closed <- closeDoor(opened)
  locked <- lockDoor(closed)
  locked
}

// Error: can't open a locked door
bad() = do {
  door <- Door<Locked>({id: 1})
  openDoor(door)                          // TYPE ERROR: expected Closed
}

// Escape hatch: unsafe cast (for when you know better)
unsafeCoerce(door: Door<a>) -> Door<b>

// More examples:

// Safe HTML (escaped vs unescaped)
type Html<safety>
type Escaped
type Unescaped

escapeHtml(h: Html<Unescaped>) -> Html<Escaped>
render(h: Html<Escaped>) -> String        // only escaped HTML can be rendered

// Validated vs unvalidated data
type FormData<validation>
type Validated
type Unvalidated

validate(data: FormData<Unvalidated>) -> Result<FormData<Validated>, Error>
submit(data: FormData<Validated>) -> Response
```

**Use Cases:**

- State machines at type level
- Validated vs unvalidated data
- Safe HTML construction
- Unit tracking (simpler than full units)
- Encoding invariants

**Implementation Notes:**

- Phantom parameter in type definition
- No runtime representation
- Simple to implement

---

### 30. Refinement Types

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **High**   |

**Description:**
Types with predicates that constrain values. Enables expressing invariants in the type system.

**Proposed Syntax:**

```primal
// Refinement type syntax: {x: Base | predicate(x)}
type PositiveInt = {n: Number | n > 0}
type NonEmptyString = {s: String | str.length(s) > 0}
type Percentage = {n: Number | n >= 0 & n <= 100}
type EvenInt = {n: Number | num.isEven(n) & num.isInteger(n)}

// Using refinement types
safeDivide(a: Number, b: {n: Number | n != 0}) -> Number

// Construction requires proof/check
x: PositiveInt = refine(5)                // OK
y: PositiveInt = refine(-3)               // RUNTIME ERROR

// Checked construction
z: Maybe<PositiveInt> = refine.check(input)  // returns Maybe

// Refinements on collections
type NonEmptyList<a> = {l: List<a> | list.length(l) > 0}
type SortedList<a> = {l: List<a> | isSorted(l)}
type BoundedList<a, n> = {l: List<a> | list.length(l) <= n}

// Function with refinement
head(l: NonEmptyList<a>) -> a             // safe head!
tail(l: NonEmptyList<a>) -> List<a>       // may be empty

// Dependent refinements
type Vector<n> = {l: List<Number> | list.length(l) == n}
dotProduct(v1: Vector<n>, v2: Vector<n>) -> Number

// Refinement subtyping
// PositiveInt is subtype of Number
sqrt(x: {n: Number | n >= 0}) -> Number
sqrt(positiveInt)                         // OK: PositiveInt implies >= 0

// Combining refinements
type ValidAge = {n: Number | n >= 0 & n <= 150 & num.isInteger(n)}

// Computed refinements
type Ascii = {s: String | all(s, (c) -> ord(c) < 128)}
```

**Use Cases:**

- Expressing invariants
- Eliminating runtime checks
- API contracts
- Data validation
- Mathematical properties

**Implementation Notes:**

- Requires SMT solver for checking
- Trade-off: expressiveness vs decidability
- May need escape hatches

---

## Language Primitives

### 31. Symbols / Atoms

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Interned identifiers that are equal if they have the same name. Lighter than strings for use as keys and tags.

**Proposed Syntax:**

```primal
// Symbol literal with colon prefix
status = :ok
error = :error
direction = :north

// Symbols are interned (same name = same identity)
:ok == :ok                                // true (identity comparison)

// Common uses

// As map keys (more efficient than string keys)
response = {
  :status: 200,
  :body: "Hello",
  :headers: {:content_type: "text/plain"}
}
response[:status]                         // 200

// As enum-like values
handleDirection(dir) = match dir with
  | :north -> [0, 1]
  | :south -> [0, -1]
  | :east -> [1, 0]
  | :west -> [-1, 0]

// As tags in tagged unions
result1 = [:ok, 42]
result2 = [:error, "not found"]

processResult(r) = match r with
  | [:ok, value] -> "Success: " + to.string(value)
  | [:error, msg] -> "Error: " + msg

// Symbol functions
symbol.name(:hello)                       // "hello"
symbol.fromString("hello")                // :hello
is.symbol(:ok)                            // true
is.symbol("ok")                           // false

// Dynamic symbol creation
sym = symbol.fromString("dynamic_" + to.string(id))

// Keyword arguments (symbols as parameter names)
createUser(:name, "Alice", :age, 30, :active, true)
```

**Use Cases:**

- Map keys
- Pattern matching tags
- Enum-like constants
- Message passing
- Keyword arguments

**Implementation Notes:**

- Global symbol table (interning)
- O(1) equality comparison
- Minimal memory per unique symbol

---

### 32. Quotation / Quasi-quotation

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
Code as data - the ability to quote expressions and splice values into quoted code. Foundation for metaprogramming.

**Proposed Syntax:**

```primal
// Quote: treat code as data (unevaluated AST)
expr1 = '(1 + 2)                          // quoted expression
expr2 = '(x * x)                          // quoted with free variable

// Quote returns AST node
// '(1 + 2) = Call('+', [Lit(1), Lit(2)])

// Eval: evaluate quoted expression
eval('(1 + 2))                            // 3

// Quasi-quote: quote with holes for splicing
x = 5
expr3 = `(1 + ~x)                         // splice x into quote
// Result: '(1 + 5)

y = '(a + b)
expr4 = `(~y * 2)                         // splice quoted expression
// Result: '((a + b) * 2)

// Splice list of expressions
args = ['(1), '(2), '(3)]
expr5 = `(f(~@args))                      // splice list
// Result: '(f(1, 2, 3))

// AST manipulation
quote.isCall(expr1)                       // true
quote.isLiteral('(42))                    // true
quote.callee('(f(x)))                     // '(f)
quote.args('(f(x, y)))                    // ['(x), '(y)]

// Build AST programmatically
quote.call('+', [quote.lit(1), quote.lit(2)])
// Same as '(1 + 2)

// Pattern matching on AST
transform(expr) = match expr with
  | '(~a + 0) -> a                        // x + 0 = x
  | '(0 + ~a) -> a                        // 0 + x = x
  | '(~a * 1) -> a                        // x * 1 = x
  | '(1 * ~a) -> a                        // 1 * x = x
  | other -> other

// Hygienic macros (if supported)
@macro unless(cond, body) = `(if (~cond) () else ~body)

unless(isEmpty(list), process(list))
// Expands to: if (isEmpty(list)) () else process(list)
```

**Use Cases:**

- Code generation
- DSL implementation
- Optimization passes
- Symbolic computation
- Compile-time metaprogramming

**Implementation Notes:**

- Quote returns AST representation
- Hygiene for macro system
- Clear evaluation semantics

---

### 33. Multi-methods

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **Medium** |

**Description:**
Functions that dispatch based on the runtime types of multiple arguments, not just one (like traditional OOP).

**Proposed Syntax:**

```primal
// Declare multi-method
multimethod collide(a, b)

// Define implementations for specific type combinations
method collide(a: Asteroid, b: Asteroid) =
  "asteroids bounce"

method collide(a: Asteroid, b: Spaceship) =
  "spaceship destroyed"

method collide(a: Spaceship, b: Asteroid) =
  collide(b, a)                           // delegate to above

method collide(a: Spaceship, b: Spaceship) =
  "both ships damaged"

// Dispatch is symmetric - order doesn't matter for lookup
collide(asteroid1, ship1)                 // "spaceship destroyed"
collide(ship1, asteroid1)                 // "spaceship destroyed"

// Default method
method collide(a, b) =
  "default collision behavior"

// Multi-method on more than 2 args
multimethod render(shape, material, light)

method render(s: Circle, m: Matte, l: PointLight) = ...
method render(s: Circle, m: Glossy, l: PointLight) = ...
method render(s: Square, m: Matte, l: Ambient) = ...

// Hierarchical dispatch (if type hierarchy exists)
type Shape
type Circle extends Shape
type Square extends Shape

method area(s: Shape) = "unknown"         // default
method area(s: Circle) = num.pi * s.radius * s.radius
method area(s: Square) = s.side * s.side

// Custom dispatch function
multimethod jsonEncode(value) using typeof

method jsonEncode(value: Number) = to.string(value)
method jsonEncode(value: String) = "\"" + escape(value) + "\""
method jsonEncode(value: Boolean) = if (value) "true" else "false"
method jsonEncode(value: List) = "[" + str.join(list.map(value, jsonEncode), ",") + "]"
method jsonEncode(value: Map) = "{" + ... + "}"
```

**Use Cases:**

- Game collision systems
- Serialization
- Visitor pattern replacement
- Graphics rendering
- Binary operations on mixed types

**Implementation Notes:**

- Dispatch table indexed by type tuple
- Caching for performance
- Clear precedence rules

---

### 34. Debug / Trace Expressions

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Non-invasive debugging that prints intermediate values without changing program behavior.

**Proposed Syntax:**

```primal
// Basic trace: prints and returns value
x = trace(expensive_computation())
// Prints: "trace: 42"
// x = 42

// Trace with label
y = trace("result", some_function())
// Prints: "result: [1, 2, 3]"

// Trace expression and result
z = traceExpr(a + b * c)
// Prints: "a + b * c = 14"

// Trace function calls (shows args and result)
@traced
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)

factorial(5)
// Prints:
// factorial(5)
//   factorial(4)
//     factorial(3)
//       factorial(2)
//         factorial(1)
//         => 1
//       => 2
//     => 6
//   => 24
// => 120

// Conditional trace
traceWhen(condition, "label", value)
// Only prints when condition is true

// Trace to custom output
traceTo(logger, "event", value)

// Assert with message (throws if false)
assert(x > 0, "x must be positive")

// Debug breakpoint (in REPL/debug mode)
debug()                                   // pauses execution
debugWith(x, y, z)                        // pauses with bindings

// Inspect type at runtime
traceType(value)
// Prints: "type: List<Number>"

// Timing
timed("operation", () -> expensive())
// Prints: "operation: 1234ms"
// Returns result of expensive()

// Count evaluations
counted("loop", () -> iteration())
// After execution, prints: "loop: 1000 times"

// Stack trace on error
withStackTrace(computation())
// On error, prints full call stack
```

**Use Cases:**

- Debugging during development
- Performance profiling
- Understanding recursion
- Validating assumptions

**Implementation Notes:**

- `trace` returns its argument unchanged
- Should have minimal/no overhead when disabled
- Integration with REPL

---

### 35. First-Class Environments

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **Low**    |

**Description:**
Ability to capture, manipulate, and evaluate code within explicit environments/scopes.

**Proposed Syntax:**

```primal
// Capture current environment
env1 = environment.current()

// Create empty environment
env2 = environment.empty()

// Create environment with bindings
env3 = environment.fromMap({
  "x": 10,
  "y": 20,
  "add": (a, b) -> a + b
})

// Extend environment
env4 = environment.extend(env3, "z", 30)

// Look up in environment
environment.lookup(env3, "x")             // some(10)
environment.lookup(env3, "w")             // nothing

// Evaluate expression in environment
environment.eval(env3, '(x + y))          // 30
environment.eval(env4, '(add(x, z)))      // 40

// Get all bindings
environment.bindings(env3)                // {"x": 10, "y": 20, "add": <fn>}
environment.names(env3)                   // ["x", "y", "add"]

// Check if binding exists
environment.has(env3, "x")                // true

// Create closure explicitly
makeAdder(env, n) =
  environment.closure(
    environment.extend(env, "n", n),
    '(x) -> x + n)
  )

addFive = makeAdder(environment.empty(), 5)
addFive(10)                               // 15

// Sandbox evaluation
safEval(code) =
  environment.eval(
    environment.sandbox(),                // restricted environment
    code
  )
```

**Use Cases:**

- Implementing REPLs
- Sandboxed evaluation
- Dynamic scoping
- Testing with mock environments

**Implementation Notes:**

- Environment = map from names to values
- Closure = (environment, expression)
- Security considerations for eval

---

### 36. Keyword Arguments as Values

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
First-class keyword arguments that can be passed around, merged, and applied to functions.

**Proposed Syntax:**

```primal
// Keyword argument syntax
result = createUser(name: "Alice", age: 30, active: true)

// Keywords as a map-like value
kwargs = {name: "Alice", age: 30}
result = createUser(**kwargs)             // spread keywords

// Merge keywords
defaults = {active: true, role: "user"}
overrides = {name: "Bob", role: "admin"}
merged = kwargs.merge(defaults, overrides)
// {active: true, role: "admin", name: "Bob"}

// Function capturing keywords
configure(**opts) = do {
  name <- opts.name ?? "default"
  port <- opts.port ?? 8080
  {name: name, port: port}
}

// Partial application with keywords
boundFn = createUser.bind(active: true)
boundFn(name: "Alice", age: 30)

// Extract keywords
takeKeywords(required, **rest) = do {
  // required is positional
  // rest contains all keyword args
  ...
}

// Required vs optional keywords
createUser(name:, age:, active: true) = ...  // name, age required; active optional

// Keyword-only (no positional)
configure(*, host:, port:) = ...          // must use keywords
configure(host: "localhost", port: 8080)

// Destructuring keywords
{name:, age:, ...rest} = userKwargs
```

**Use Cases:**

- Readable function calls
- Configuration objects
- Builder patterns
- API design

**Implementation Notes:**

- Keywords as special map type
- Compile-time or runtime checking
- Integration with partial application

---

## Testing & Verification

### 37. Property-Based Testing

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Built-in support for generating random test data and checking properties hold for all inputs.

**Proposed Syntax:**

```primal
// Basic property test
@property
reverseReverse(lst: List<Number>) =
  list.reverse(list.reverse(lst)) == lst

// Property with custom generator
@property
sortedIsSorted(lst: List<Number>) =
  isSorted(list.sort(lst, num.compare))

// Generators
gen.number()                              // any number
gen.number(0, 100)                        // range
gen.string()                              // any string
gen.string(gen.alphaNum(), 1, 20)         // alphanumeric, 1-20 chars
gen.list(gen.number())                    // list of numbers
gen.list(gen.number(), 0, 10)             // 0-10 elements
gen.map(gen.string(), gen.number())
gen.oneOf([1, 2, 3])                      // choose from list
gen.frequency([(3, gen.number()), (1, gen.string())])  // weighted

// Custom generators
personGen = gen.map3(
  gen.string(gen.alpha(), 1, 50),
  gen.number(0, 120),
  gen.bool(),
  (name, age, active) -> {name: name, age: age, active: active}
)

// Conditional generation
evenGen = gen.filter(gen.number(), num.isEven)
nonEmptyGen = gen.filter(gen.list(gen.number()), list.isNotEmpty)

// Sized generation (grows with test size)
gen.sized((size) -> gen.list(gen.number(), 0, size))

// Running properties
prop.check(reverseReverse)
// Output: OK, passed 100 tests

prop.check(reverseReverse, {tests: 1000})
// More iterations

// Shrinking (finds minimal failing case)
@property
buggyProperty(n: Number) = n < 100
// Failing input shrinks: 2847 -> 234 -> 105 -> 100

// Labeling (for coverage statistics)
@property
insertProperty(x: Number, lst: List<Number>) =
  let sorted = list.sort(lst, num.compare)
  let inserted = sortedInsert(x, sorted)
  label(if (list.isEmpty(lst)) "empty" else "non-empty") &
  isSorted(inserted) & list.contains(inserted, x)

// Implication (skip invalid inputs)
@property
divisionProperty(a: Number, b: Number) =
  (b != 0) ==> (a / b * b == a)

// Expecting failure
@property @expectFailure
knownBug(x: Number) = false

// Collecting statistics
@property
distribution(x: Number) =
  collect(if (x > 0) "positive" else "non-positive", true)
```

**Use Cases:**

- Finding edge cases
- Testing algebraic properties
- Fuzz testing
- API contract verification

**Implementation Notes:**

- Integrate with generator monad
- Shrinking for minimal counterexamples
- Reproducible with seeds

---

### 38. Soft Invariants / Contracts

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Declarative pre-conditions, post-conditions, and invariants that can be checked at runtime or documented.

**Proposed Syntax:**

```primal
// Pre-condition
@require(n >= 0)
@require(n < 1000, "n must be reasonable")
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)

// Post-condition
@ensure(result > 0)
@ensure(result >= n, "result must be at least n")
fibonacci(n) = ...

// Both
@require(b != 0)
@ensure(result * b == a)
divide(a, b) = a / b

// Invariants on data
@invariant(self.balance >= 0)
type Account = {balance: Number, owner: String}

// Contract as expression
contract(
  pre: x > 0,
  post: (result) -> result > x,
  body: x * 2
)

// Soft contracts (warn, don't fail)
@softRequire(lst.length < 1000, "performance warning")
processLarge(lst) = ...

// Contract modes (configurable)
// contract.mode = :enforce (throw on violation)
// contract.mode = :warn (log warning)
// contract.mode = :document (no runtime check)
// contract.mode = :off (completely disabled)

// Dependent contracts
@require(list.length(weights) == list.length(values))
weightedSum(weights, values) = ...

// Higher-order contracts
@require(is.function(f))
@ensure((result) -> is.function(result))
compose(f, g) = (x) -> f(g(x))

// Contract blame (who violated?)
@require(is.string(name), blame: :caller)
greet(name) = "Hello, " + name

// Old values in postcondition
@ensure((result) -> result == old(balance) + amount)
deposit(account, amount) = ...
```

**Use Cases:**

- API documentation
- Runtime validation
- Design by contract
- Debugging

**Implementation Notes:**

- Configurable enforcement level
- Integrate with error messages
- Support for `old` values

---

### 39. Snapshot Testing

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Compare output against previously saved "golden" outputs. Useful for testing complex outputs.

**Proposed Syntax:**

```primal
// Basic snapshot test
@snapshot("render_user")
testRenderUser() = renderUser({name: "Alice", age: 30})

// First run: saves output to __snapshots__/render_user.snap
// Subsequent runs: compares against saved snapshot

// Update snapshots (when intentional changes)
// Run with: primal test --update-snapshots

// Inline snapshots (stored in test file)
@inlineSnapshot
testFormat() = formatData(input)
// Primal updates the test file with actual output

// Named snapshots in one test
testMultiple() = do {
  snapshot("case1", render(data1))
  snapshot("case2", render(data2))
  snapshot("case3", render(data3))
}

// Custom serializer
@snapshot("custom", serializer: jsonPretty)
testCustom() = complexDataStructure()

// Snapshot with matcher (partial matching)
@snapshot("partial", match: :substring)
testPartial() = generateReport()

// Diff on failure
// Shows:
// - Expected (from snapshot)
// + Actual (from test)
// With line-by-line diff

// Snapshot directory structure
// __snapshots__/
//   test_file_name/
//     snapshot_name.snap

// Programmatic snapshot
snapshot.assert("name", value)
snapshot.update("name", value)            // force update
snapshot.read("name")                     // get stored value
```

**Use Cases:**

- UI component testing
- Serialization output
- Report generation
- API response testing

**Implementation Notes:**

- File-based storage
- Clear diff output
- Update workflow

---

## Syntax Sugar & Ergonomics

### 40. Case Expressions

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Multi-way conditionals that are more readable than nested if-else chains.

**Proposed Syntax:**

```primal
// Basic case expression
grade(score) = case
  | score >= 90 -> "A"
  | score >= 80 -> "B"
  | score >= 70 -> "C"
  | score >= 60 -> "D"
  | otherwise   -> "F"

// Case on specific value
describe(n) = case n of
  | 0 -> "zero"
  | 1 -> "one"
  | 2 -> "two"
  | _ -> "many"

// Case with guards
classify(x, y) = case
  | x == 0 & y == 0 -> "origin"
  | x == 0          -> "y-axis"
  | y == 0          -> "x-axis"
  | x == y          -> "diagonal"
  | otherwise       -> "general"

// Case with pattern matching (if pattern matching exists)
listCase(lst) = case lst of
  | []           -> "empty"
  | [x]          -> "singleton: " + to.string(x)
  | [x, y]       -> "pair"
  | [x, y, ...rest] -> "at least three"

// Case with binding
parseResult(r) = case r of
  | [:ok, value]    -> "Success: " + to.string(value)
  | [:error, msg]   -> "Error: " + msg
  | [:pending]      -> "Still waiting..."

// Nested case
processInput(input) = case input of
  | {:type: "number", :value: v} -> case
    | v > 0     -> "positive"
    | v < 0     -> "negative"
    | otherwise -> "zero"
  | {:type: "string", :value: v} -> "text: " + v

// Case as expression (returns value)
result = case computeSomething() of
  | [:success, x] -> x
  | [:failure, _] -> defaultValue
```

**Use Cases:**

- Replacing nested if-else
- State machines
- Input classification
- Readable conditionals

**Implementation Notes:**

- Desugar to nested if-else
- Pattern matching integration
- Exhaustiveness checking (optional)

---

### 41. When Expressions

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Conditional expression for when you only care about the true case (like Ruby's unless/when).

**Proposed Syntax:**

```primal
// when: execute if condition true, return nothing otherwise
when(condition, value)

// Usage
result = when(score > 90, "Excellent!")
// If score > 90: "Excellent!"
// Otherwise: nothing (or unit)

// unless: opposite of when
unless(condition, value)
result = unless(list.isEmpty(lst), list.first(lst))

// when with multiple conditions
result = when {
  | score > 90 -> "A"
  | score > 80 -> "B"
}
// Returns first matching, or nothing

// when-let: bind and check
whenLet(maybeValue, (v) -> process(v))
// If maybeValue is some(x), calls process(x)
// If nothing, returns nothing

// Example
result = whenLet(map.get(data, "name"), (name) ->
  "Hello, " + name
)

// unless-let
unlessLet(errorValue, (e) -> logError(e))

// when-some (for multiple optionals)
result = whenSome(
  [map.get(m, "x"), map.get(m, "y")],
  ([x, y]) -> x + y
)
// Only executes if all are some

// when in pipeline
data
  |> process
  |> when(condition, transform)
  |> finalize
```

**Use Cases:**

- Optional execution
- Null checks
- Conditional transformation
- Guard clauses

**Implementation Notes:**

- Simple desugaring
- Works with Maybe/Option type
- Pipeline friendly

---

### 42. With Expressions

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Scoped bindings that are only available within an expression. Cleaner than nested lets.

**Proposed Syntax:**

```primal
// Basic with expression
result = with {
  x = 10
  y = 20
  z = x + y
} in x * y * z

// Equivalent to nested lets but cleaner
// let x = 10 in let y = 20 in let z = x + y in x * y * z

// With destructuring
result = with {
  {name:, age:} = person
  greeting = "Hello, " + name
} in greeting + " (age " + to.string(age) + ")"

// Mutually dependent (in order)
result = with {
  a = 1
  b = a + 1        // can reference a
  c = a + b        // can reference a and b
} in [a, b, c]

// With function definitions
result = with {
  square(x) = x * x
  cube(x) = x * square(x)
} in cube(3)

// Resource-like with (cleanup after)
result = withResource {
  file = file.open("data.txt")
} do {
  file.read(file)
} finally {
  file.close(file)
}

// With for computed temporary values
quadraticRoots(a, b, c) = with {
  discriminant = b*b - 4*a*c
  sqrtD = num.sqrt(discriminant)
  denom = 2 * a
} in [(-b + sqrtD) / denom, (-b - sqrtD) / denom]

// Inline with (for simple cases)
result = (with x = 10 in x * x)
```

**Use Cases:**

- Complex calculations with intermediates
- Avoiding repeated expressions
- Scoped helper functions
- Readable complex expressions

**Implementation Notes:**

- Desugar to let bindings
- Sequential binding semantics
- Block-level scoping

---

### 43. Placeholder Arguments

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Shorthand for creating anonymous functions using placeholders like `_` for arguments.

**Proposed Syntax:**

```primal
// Instead of: (x) -> x + 1
list.map(numbers, _ + 1)

// Instead of: (x) -> x * 2
list.map(numbers, _ * 2)

// Instead of: (x) -> num.isEven(x)
list.filter(numbers, num.isEven(_))

// Multiple placeholders (different args)
// Instead of: (a, b) -> a + b
list.reduce(numbers, 0, _1 + _2)

// Instead of: (a, b) -> a > b
list.sort(items, _1 > _2)

// Placeholder in nested calls
list.map(users, _.name)                   // extract name field
list.map(users, str.uppercase(_.name))

// Placeholder with methods (if method syntax exists)
list.map(strings, _.uppercase())

// Multiple uses of same placeholder = same argument
// _ + _ means (x) -> x + x, NOT (x, y) -> x + y
list.map(numbers, _ + _)                  // doubles

// Use _1, _2 for distinct arguments
list.zipWith(as, bs, _1 + _2)             // (a, b) -> a + b

// Placeholder in conditions
list.filter(users, _.age > 18)

// Not using placeholder = partial application
list.map(numbers, num.add(5, _))          // add 5 to each

// Nested placeholders (innermost scope)
list.map(lists, list.map(_, _ * 2))
// = list.map(lists, (l) -> list.map(l, (x) -> x * 2))
```

**Use Cases:**

- Concise lambdas
- Point-free style
- Readable transformations
- Quick predicates

**Implementation Notes:**

- Parse `_` specially in expression position
- Wrap in minimal lambda
- Handle multiple placeholders

---

### 44. Method Chaining Syntax

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Low**    |
| Impact     | **High**   |

**Description:**
Allow calling functions in method style for better readability of transformation chains.

**Proposed Syntax:**

```primal
// Instead of: list.map(list.filter(numbers, isEven), double)
numbers.filter(isEven).map(double)

// Translation rule: x.f(args) = f(x, args)
// So: numbers.filter(isEven) = list.filter(numbers, isEven)

// Chaining example
result = users
  .filter(_.active)
  .map(_.name)
  .sort(str.compare)
  .take(10)
  .join(", ")

// Works with any function where first arg matches
"hello".uppercase()                       // str.uppercase("hello")
"hello".length()                          // str.length("hello")
42.abs()                                  // num.abs(42)
[1, 2, 3].reverse()                       // list.reverse([1, 2, 3])

// Chaining with additional args
"hello world".split(" ")                  // str.split("hello world", " ")
[1, 2, 3].at(1)                           // list.at([1, 2, 3], 1)

// Mixed style (both work)
str.uppercase("hello")                    // traditional
"hello".uppercase()                       // method style

// Custom functions work too
myProcess(data, options)                  // traditional
data.myProcess(options)                   // method style

// Helps with deeply nested transformations
// Before:
result = json.encode(
  list.map(
    list.filter(data, isValid),
    transform
  )
)

// After:
result = data
  .filter(isValid)
  .map(transform)
  .json.encode()                          // or: |> json.encode
```

**Use Cases:**

- Data transformation pipelines
- Fluent interfaces
- Readable chains
- Familiar to OOP developers

**Implementation Notes:**

- Purely syntactic transformation
- `x.f(args)` → `f(x, args)`
- No method resolution, just function call

---

## Summary

This document proposes 44 new features for the Primal programming language, organized into 7 categories:

| Category                | Count | High Impact                          |
| ----------------------- | ----- | ------------------------------------ |
| Data Types & Structures | 10    | Matrices, Graphs, Trees              |
| Functional Patterns     | 8     | Lenses, Transducers, Trampolining    |
| Effects & Control Flow  | 6     | Validation, Async, Algebraic Effects |
| Type System             | 6     | Newtypes, Row Polymorphism           |
| Language Primitives     | 6     | Symbols, Debug/Trace                 |
| Testing & Verification  | 3     | Property-Based Testing               |
| Syntax Sugar            | 5     | Placeholder Args, Method Chaining    |

**Recommended Priority (High Fit + High Impact + Low/Medium Complexity):**

1. Debug/Trace Expressions - immediate developer productivity
2. Validation Type - essential for real applications
3. Trampolining - enables deep recursion safely
4. Placeholder Arguments - major ergonomic improvement
5. Case Expressions - cleaner conditionals
6. Symbols/Atoms - efficient tags and keys
7. NonEmpty Collections - type safety
8. Method Chaining - readability
9. Property-Based Testing - testing quality
10. Lenses - functional data manipulation
