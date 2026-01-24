---
title: use() Hook for Promises and Context
impact: HIGH
impactDescription: Cleaner async data reading and conditional context
tags: react19, use, promises, context, suspense
---

## use() Hook for Promises and Context

**Impact: HIGH (cleaner async data reading and conditional context)**

The `use()` hook can read promises (suspends until resolved) and read context conditionally (unlike `useContext`).

**Reading promises:**

```typescript
import { use } from "react";

function Comments({ promise }) {
  const comments = use(promise);
  return comments.map(c => <div key={c.id}>{c.text}</div>);
}

// Parent passes the promise, Suspense handles loading
<Suspense fallback={<Loading />}>
  <Comments promise={fetchComments()} />
</Suspense>
```

**Conditional context (not possible with useContext):**

```typescript
import { use } from "react";

function Theme({ showTheme }) {
  if (showTheme) {
    const theme = use(ThemeContext);
    return <div style={{ color: theme.primary }}>Themed</div>;
  }
  return <div>Plain</div>;
}
```

Reference: [use Hook](https://react.dev/reference/react/use)
