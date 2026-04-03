---
name: audit-tests
description: TODO
---

i want to create a skill in this file that will audit the tests that we have in the repository, and check if they are covering all the features that we have implemented, and if they are testing the edge cases, and if they are testing the error cases, etc.

are all the cases in one stage of the pipeline also tested in the other stages of the pipeline? for example, tests in the lexical analyzer should also be tested in the syntactic analyzer, semantic analyzer, and runtime. if not, we should add them in all stages of the pipeline.