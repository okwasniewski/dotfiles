---
title: Server Components First
impact: CRITICAL
impactDescription: Reduce client bundle, fetch data on server
tags: react19, rsc, server-components, use-client
---

## Server Components First

**Impact: CRITICAL (reduce client bundle, fetch data on server)**

Default to Server Components (no directive). Only add `"use client"` when you need client-side interactivity.

**Incorrect (unnecessary client component):**

```typescript
"use client";

export default function Page() {
  // No hooks or interactivity - doesn't need to be client
  return <div>Static content</div>;
}
```

**Correct (server component with client child):**

```typescript
// Server Component (default) - no directive needed
export default async function Page() {
  const data = await fetchData();
  return <ClientComponent data={data} />;
}

// client-component.tsx
"use client";
export function ClientComponent({ data }) {
  const [state, setState] = useState(false);
  return <button onClick={() => setState(!state)}>Toggle</button>;
}
```

**When to use "use client":**

- `useState`, `useEffect`, `useRef`, `useContext`
- Event handlers (`onClick`, `onChange`)
- Browser APIs (`window`, `localStorage`)

Reference: [Server Components](https://react.dev/reference/rsc/server-components)
