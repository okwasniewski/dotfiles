---
title: ref as Prop (No forwardRef)
impact: MEDIUM
impactDescription: Simpler component APIs
tags: react19, ref, forwardRef, props
---

## ref as Prop (No forwardRef)

**Impact: MEDIUM (simpler component APIs)**

In React 19, `ref` is a regular prop. No need for `forwardRef` wrapper.

**Incorrect (old forwardRef pattern):**

```typescript
import { forwardRef } from "react";

const Input = forwardRef((props, ref) => {
  return <input ref={ref} {...props} />;
});
```

**Correct (ref as prop):**

```typescript
function Input({ ref, ...props }) {
  return <input ref={ref} {...props} />;
}

// Usage
function Form() {
  const inputRef = useRef(null);
  return <Input ref={inputRef} placeholder="Enter text" />;
}
```

Reference: [React 19 ref as prop](https://react.dev/blog/2024/12/05/react-19#ref-as-a-prop)
