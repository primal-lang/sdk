Tagged unions / enums | Better data modelling than ad-hoc maps

Function contracts / requires | Sample programs currently spell preconditions manually with if + error.throw; this could be first- class sugar.

Function composition operators sanitize = str.trim >> str.lowercase

Tuples/records with destructuring
This would give Primal a lightweight way to model structured
data without forcing everything through maps. It also opens the
door to cleaner function returns and helper composition.

Named and default arguments
str.padLeft("42", width: 5, fill: "0")
This matters because the standard library is already large, and
many calls are hard to read positionally.
