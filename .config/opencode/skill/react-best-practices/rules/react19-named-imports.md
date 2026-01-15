---
title: Named Imports Only
impact: HIGH
impactDescription: Better tree-shaking and cleaner code
tags: react19, imports, tree-shaking
---

## Named Imports Only

**Impact: HIGH (better tree-shaking and cleaner code)**

Always use named imports from React. Default imports (`import React`) are unnecessary in React 19 with JSX transform.

**Incorrect (default/namespace imports):**

```typescript
import React from "react";
// or
import * as React from "react";

function Component() {
  const [state, setState] = React.useState(false);
  return <div>{state}</div>;
}
```

**Correct (named imports):**

```typescript
import { useState, useEffect, useRef } from "react";

function Component() {
  const [state, setState] = useState(false);
  return <div>{state}</div>;
}
```

Reference: [React 19 Release](https://react.dev/blog/2024/12/05/react-19)
