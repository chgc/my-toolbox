# Mermaid Syntax Cheatsheet

Quick reference for writing valid Mermaid diagrams.

---

## Flowchart / Graph

```
flowchart TD          ← top-down (most common)
flowchart LR          ← left-right
flowchart BT          ← bottom-top
flowchart RL          ← right-left
```

### Node Shapes

```
A[Rectangle]
B(Rounded)
C([Pill/Stadium])
D[[Subroutine]]
E[(Database)]
F((Circle))
G{Diamond}
H{{Hexagon}}
I[/Parallelogram/]
J>Asymmetric]
```

### Edges

```
A --> B                  ← arrow
A --- B                  ← line, no arrow
A -.-> B                 ← dashed arrow
A ==> B                  ← thick arrow
A -- "label" --> B       ← labeled arrow
A -->|label| B           ← labeled arrow (alt)
A ~~~ B                  ← invisible link (for layout)
```

### Subgraphs

```
subgraph "Group Name"
    A --> B
end
```

### Styling

```
style A fill:#d0bfff,stroke:#7048e8,color:#000
classDef myClass fill:#b2f2bb,stroke:#2f9e44
class A,B myClass
```

### Special Characters in Labels

Use quotes for labels with spaces or special chars:
```
A["Text with (parens)"]
B["Multi-word label"]
```

---

## Sequence Diagram

```
sequenceDiagram
    participant A as "Service A"
    actor User

    A->>B: request          ← solid arrow
    B-->>A: response        ← dashed arrow (return)
    A-)B: async call        ← open arrowhead
    A-xB: lost message      ← cross

    activate B
    deactivate B

    loop Every 5s
        A->>B: heartbeat
    end

    alt Success
        B-->>A: 200 OK
    else Error
        B-->>A: 500 Error
    end

    par in parallel
        A->>B: call 1
    and
        A->>C: call 2
    end

    note over A,B: This is a note
    note right of A: Note on A
```

---

## Class Diagram

```
classDiagram
    class Animal {
        +String name
        -int age
        #String species
        +speak() void
        +move()* void    ← abstract
    }

    class Dog {
        +String breed
        +fetch() void
    }

    Animal <|-- Dog          ← inheritance
    Cat *-- Paw              ← composition
    Dog o-- Collar           ← aggregation
    Dog --> Owner            ← association
    Dog .. Vet               ← dependency

    Animal "1" --> "0..*" Home : lives in
```

---

## ER Diagram

```
erDiagram
    ENTITY_NAME {
        type field_name PK
        type field_name FK
        type field_name
    }

    A ||--o{ B : "relationship label"
```

**Cardinality:**
```
||   exactly one
o|   zero or one
|{   one or more
o{   zero or more
```

---

## State Diagram

```
stateDiagram-v2
    [*] --> State1           ← start
    State1 --> State2 : event
    State2 --> [*]           ← end

    state State1 {           ← composite state
        [*] --> Sub1
        Sub1 --> Sub2
    }

    [*] --> Fork
    state Fork <<fork>>
    Fork --> BranchA
    Fork --> BranchB
```

---

## Gantt

```
gantt
    title My Title
    dateFormat YYYY-MM-DD
    excludes weekends

    section Section
        Task 1   :done,     id1, 2024-01-01, 7d
        Task 2   :active,   id2, after id1, 5d
        Milestone:milestone, m1, 2024-01-15, 0d
        Task 3   :crit,     id3, 2024-01-16, 10d
```

**Task states:** `done`, `active`, `crit`, `milestone`
**Duration:** `7d`, `2w`, or end date `2024-01-31`

---

## Pie Chart

```
pie showData
    title My Title
    "Category A" : 42.5
    "Category B" : 30.0
    "Category C" : 27.5
```

---

## Git Graph

```
gitGraph
    commit
    commit id: "named commit"
    commit tag: "v1.0"

    branch feature
    checkout feature
    commit
    commit

    checkout main
    merge feature

    branch release
    checkout release
    commit
    checkout main
    merge release tag: "v2.0"
```

---

## Mindmap

```
mindmap
  root((Root Topic))
    Branch A
      Leaf 1
      Leaf 2
    Branch B
      ::icon(fa fa-star)
      Sub-branch
        Deep leaf
```

---

## Common Mistakes to Avoid

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `A(text with (nested parens))` | `A["text with (nested parens)"]` |
| Arrow with no space: `A-->B` | `A --> B` (spaces recommended) |
| Unclosed subgraph | Always close with `end` |
| `stateDiagram` | Use `stateDiagram-v2` |
| Duplicate node IDs | Each node ID must be unique |
| Chinese/CJK without quotes | `A["中文標籤"]` — wrap in quotes |

---

## Mermaid Live Editor

Test diagrams at: https://mermaid.live
