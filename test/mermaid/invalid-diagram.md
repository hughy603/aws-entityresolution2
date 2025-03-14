# Invalid Mermaid Diagram Test

This file contains an invalid Mermaid diagram.

```mermaid
flowchart LR
    A[Start] --> B{Is it valid?}
    B ->|Yes| C[Success]  <!-- Missing an arrow character -->
    B -->|No| D[Failure]
    C -> E[End]  <!-- Missing an arrow character -->
    D -->
```
