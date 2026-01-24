---
title: No Manual Memoization
impact: CRITICAL
impactDescription: React Compiler handles optimization automatically
tags: react19, compiler, memoization, useMemo, useCallback
---

## No Manual Memoization

**Impact: CRITICAL (React Compiler handles optimization automatically)**

React 19's Compiler automatically memoizes values and callbacks. Manual `useMemo` and `useCallback` are unnecessary and add noise.

**Incorrect (manual memoization):**

```typescript
function Component({ items }) {
  const filtered = useMemo(() => items.filter(x => x.active), [items]);
  const handleClick = useCallback((id) => console.log(id), []);

  return <List items={filtered} onClick={handleClick} />;
}
```

**Correct (let compiler optimize):**

```typescript
function Component({ items }) {
  const filtered = items.filter(x => x.active);
  const sorted = filtered.sort((a, b) => a.name.localeCompare(b.name));

  const handleClick = (id) => {
    console.log(id);
  };

  return <List items={sorted} onClick={handleClick} />;
}
```

Reference: [React Compiler](https://react.dev/learn/react-compiler)
