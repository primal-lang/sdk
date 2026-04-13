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
