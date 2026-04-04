Maps are flexible but weakly communicative. Records would give Primal a lightweight way to model structured data with named fields.

**Design notes:**

- A dynamic first version does not need field type annotations.
- Field access and functional update are the key capabilities.
- A simple implementation could lower records to tagged maps at first.
- This interacts with the lexer/parser because dot access is not currently a general expression form.

Add named-field structures:

```
record Person(name, age)

alice = Person("Alice", 30)
name = alice.name
older = alice with { age: 31 }
```
