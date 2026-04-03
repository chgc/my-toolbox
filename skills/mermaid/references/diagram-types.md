# Mermaid Diagram Types — Reference

All diagram types supported by Mermaid v11 with complete, copy-ready examples.

---

## flowchart / graph

**Use for:** Process flows, architecture diagrams, decision trees, system overviews.

```mermaid
flowchart TD
    A[Start] --> B{Is user logged in?}
    B -->|Yes| C[Show dashboard]
    B -->|No| D[Redirect to login]
    D --> E[User logs in]
    E --> C
    C --> F[End]
```

**Direction options:** `TD` (top-down), `LR` (left-right), `BT` (bottom-top), `RL` (right-left)

**Node shapes:**
| Syntax | Shape |
|--------|-------|
| `[text]` | Rectangle |
| `(text)` | Rounded rectangle |
| `([text])` | Stadium / pill |
| `[[text]]` | Subroutine / double rectangle |
| `[(text)]` | Cylindrical (database) |
| `((text))` | Circle |
| `{text}` | Diamond (decision) |
| `{{text}}` | Hexagon |
| `[/text/]` | Parallelogram |
| `[\\text\\]` | Parallelogram (alt) |
| `>text]` | Asymmetric |

**Edge types:**
| Syntax | Meaning |
|--------|---------|
| `-->` | Solid arrow |
| `---` | Solid line (no arrow) |
| `-.->` | Dashed arrow |
| `==>` | Thick arrow |
| `--\|label\|-->` | Arrow with label |
| `-- label -->` | Arrow with label (alt) |

---

## sequenceDiagram

**Use for:** API interactions, user flows, protocol handshakes, microservice communication.

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant API
    participant DB

    User->>Frontend: Click "Buy"
    Frontend->>API: POST /orders {items}
    API->>DB: INSERT order
    DB-->>API: order_id
    API-->>Frontend: 201 {order_id}
    Frontend-->>User: "Order confirmed!"

    note over API,DB: Transaction committed
```

**Message types:**
| Syntax | Type |
|--------|------|
| `A->>B: msg` | Solid arrow |
| `A-->>B: msg` | Dashed arrow (response) |
| `A-)B: msg` | Async arrow |
| `A-xB: msg` | Cross (lost message) |

**Modifiers:** `activate A` / `deactivate A`, `loop`, `alt`/`else`/`end`, `par`, `note over A,B:`

---

## classDiagram

**Use for:** OOP class hierarchies, data models, interface definitions.

```mermaid
classDiagram
    class User {
        +int id
        +string email
        +string name
        +login() bool
        +logout() void
    }

    class Admin {
        +string role
        +manageUsers() void
    }

    class Order {
        +int id
        +decimal total
        +string status
        +confirm() void
    }

    User <|-- Admin : extends
    User "1" --> "0..*" Order : places
```

**Visibility:** `+` public, `-` private, `#` protected, `~` package

**Relationships:**
| Syntax | Relationship |
|--------|-------------|
| `<\|--` | Inheritance |
| `*--` | Composition |
| `o--` | Aggregation |
| `-->` | Association |
| `--` | Link |
| `..>` | Dependency |
| `..\|>` | Realization |

---

## erDiagram

**Use for:** Database schema, entity relationships, data modeling.

```mermaid
erDiagram
    CUSTOMER {
        int id PK
        string name
        string email
        string phone
    }
    ORDER {
        int id PK
        int customer_id FK
        datetime created_at
        string status
        decimal total
    }
    PRODUCT {
        int id PK
        string name
        decimal price
        int stock
    }
    ORDER_ITEM {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal unit_price
    }

    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : "included in"
```

**Cardinality:**
| Syntax | Meaning |
|--------|---------|
| `\|\|` | Exactly one |
| `o\|` | Zero or one |
| `\|\{` | One or more |
| `o\{` | Zero or more |

---

## stateDiagram-v2

**Use for:** State machines, lifecycle diagrams, workflow states.

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Processing : submit order
    Processing --> Shipped : payment confirmed
    Processing --> Cancelled : payment failed
    Shipped --> Delivered : carrier update
    Delivered --> [*]
    Cancelled --> [*]

    state Processing {
        [*] --> ValidatingPayment
        ValidatingPayment --> ChargingCard
        ChargingCard --> [*]
    }
```

---

## gantt

**Use for:** Project timelines, sprint planning, roadmaps.

```mermaid
gantt
    title Q1 Development Roadmap
    dateFormat  YYYY-MM-DD
    section Backend
        Auth Service        :done,    a1, 2024-01-01, 2024-01-15
        API Gateway         :active,  a2, 2024-01-10, 2024-01-25
        Order Service       :         a3, 2024-01-20, 2024-02-10
    section Frontend
        Login page          :done,    f1, 2024-01-05, 2024-01-18
        Dashboard           :         f2, 2024-01-15, 2024-02-05
        Order flow          :         f3, 2024-02-01, 2024-02-20
    section QA
        Integration tests   :         q1, 2024-02-10, 2024-02-25
        UAT                 :         q2, 2024-02-20, 2024-03-01
```

**Task states:** `done`, `active`, `crit` (critical), `milestone`

---

## pie

**Use for:** Proportional data, breakdowns, distributions.

```mermaid
pie title API Error Distribution
    "4xx Client Errors" : 45.2
    "5xx Server Errors" : 12.8
    "Timeouts"          : 8.5
    "Network Errors"    : 3.5
    "Success"           : 30.0
```

---

## gitGraph

**Use for:** Git branching strategy, release flow, trunk-based development.

```mermaid
gitGraph
    commit id: "Initial commit"
    branch develop
    checkout develop
    commit id: "Add auth"
    branch feature/login
    checkout feature/login
    commit id: "Login form"
    commit id: "Login API"
    checkout develop
    merge feature/login id: "Merge login"
    branch release/1.0
    checkout release/1.0
    commit id: "Bump version"
    checkout main
    merge release/1.0 id: "v1.0.0" tag: "v1.0"
```

---

## mindmap

**Use for:** Brainstorming, concept hierarchies, topic breakdowns.

```mermaid
mindmap
  root((System Design))
    Frontend
      React
      Next.js
      Tailwind CSS
    Backend
      Node.js
      FastAPI
      PostgreSQL
    Infrastructure
      Docker
      Kubernetes
      AWS
    Monitoring
      Prometheus
      Grafana
      Loki
```

---

## timeline

**Use for:** Historical events, product roadmaps, milestones.

```mermaid
timeline
    title Product Roadmap 2024
    Q1 : Auth & User Management
       : Payment Integration
    Q2 : Mobile App (iOS)
       : Analytics Dashboard
    Q3 : Mobile App (Android)
       : API v2
    Q4 : Enterprise Features
       : Global Launch
```

---

## xychart-beta

**Use for:** Bar charts, line charts, data visualization.

```mermaid
xychart-beta
    title "Monthly Revenue (USD)"
    x-axis [Jan, Feb, Mar, Apr, May, Jun]
    y-axis "Revenue" 0 --> 50000
    bar [12000, 18000, 25000, 31000, 27000, 42000]
    line [12000, 18000, 25000, 31000, 27000, 42000]
```
