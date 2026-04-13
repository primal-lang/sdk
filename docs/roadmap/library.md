2. Number Module



3. List Module

Function: list.flatten
Signature: (a: List): List
Description: Flatten nested lists one level
────────────────────────────────────────
Function: list.distinct
Signature: (a: List): List
Description: Remove duplicates
────────────────────────────────────────
Function: list.count
Signature: (a: List, b: Function): Number
Description: Count elements matching predicate
────────────────────────────────────────
Function: list.chunk
Signature: (a: List, b: Number): List
Description: Split into chunks of size n
────────────────────────────────────────

4. Map Module

Function: map.merge
Signature: (a: Map, b: Map): Map
Description: Merge maps (b overrides a)
────────────────────────────────────────
Function: map.entries
Signature: (a: Map): List
Description: List of [key, value] pairs
────────────────────────────────────────

5. Set Module

Function: set.isSubset
Signature: (a: Set, b: Set): Boolean
Description: Is a subset of b?
────────────────────────────────────────
Function: set.isSuperset
Signature: (a: Set, b: Set): Boolean
Description: Is a superset of b?
────────────────────────────────────────
Function: set.isDisjoint
Signature: (a: Set, b: Set): Boolean
Description: No common elements?
────────────────────────────────────────

6. Timestamp Module

Function: time.fromEpoch
Signature: (a: Number): Timestamp
Description: Create from epoch ms
────────────────────────────────────────
Function: time.format
Signature: (a: Timestamp, b: String): String
Description: Format with pattern
────────────────────────────────────────
Function: time.dayOfWeek
Signature: (a: Timestamp): Number
Description: Day 1-7 (Mon=1)
────────────────────────────────────────
Function: time.dayOfYear
Signature: (a: Timestamp): Number
Description: Day 1-366
────────────────────────────────────────
Function: time.isLeapYear
Signature: (a: Number): Boolean
Description: Check leap year
────────────────────────────────────────
Function: time.isBefore
Signature: (a: Timestamp, b: Timestamp): Boolean
Description: Returns true if the first timestamp occurs before the second.
────────────────────────────────────────
Function: time.isAfter
Signature: (a: Timestamp, b: Timestamp): Boolean
Description: Returns true if the first timestamp occurs after the second.
────────────────────────────────────────

7. Vector Module

Function: vector.dot
Signature: (a: Vector, b: Vector): Number
Description: Dot product of two vectors
────────────────────────────────────────
Function: vector.scale
Signature: (a: Vector, b: Number): Vector
Description: Scale vector by a number
────────────────────────────────────────
Function: vector.distance
Signature: (a: Vector, b: Vector): Number
Description: Euclidean distance between two vectors
────────────────────────────────────────

8. File

Function: file.append
Signature: (a: File, b: String): Boolean
Description: Append string to file (creates if doesn't exist)
────────────────────────────────────────
Function: file.lastModified
Signature: (a: File): Timestamp
Description: Get last modified time of file

9. Environment

Function: env.has
Signature: (a: String): Boolean
Description: Check if environment variable exists

10. Base64 Module (base64.) [NEW]

Function: base64.encode
Signature: (a: String): String
Description: Encode to base64
────────────────────────────────────────
Function: base64.decode
Signature: (a: String): String
Description: Decode from base64
────────────────────────────────────────

11. Path Module (path.) [NEW]

Function: path.join
Signature: (a: String, b: String): String
Description: Join path segments
────────────────────────────────────────
Function: path.dirname
Signature: (a: String): String
Description: Directory portion
────────────────────────────────────────
Function: path.basename
Signature: (a: String): String
Description: Filename portion
────────────────────────────────────────
Function: path.extension
Signature: (a: String): String
Description: File extension
────────────────────────────────────────
Function: path.isAbsolute
Signature: (a: String): Boolean
Description: Is absolute path?
────────────────────────────────────────
Function: path.normalize
Signature: (a: String): String
Description: Normalize path
────────────────────────────────────────

12. UUID Module (uuid.) [NEW]

Function: uuid.v4
Signature: (): String
Description: Generate random UUID
────────────────────────────────────────
