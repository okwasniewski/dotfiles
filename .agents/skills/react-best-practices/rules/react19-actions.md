---
title: Actions and useActionState
impact: HIGH
impactDescription: Simplified form handling with pending states
tags: react19, actions, useActionState, forms, server-actions
---

## Actions and useActionState

**Impact: HIGH (simplified form handling with pending states)**

Use Server Actions with `useActionState` for form submissions with automatic pending state management.

**Server Action:**

```typescript
// actions.ts
"use server";

async function submitForm(formData: FormData) {
  await saveToDatabase(formData);
  revalidatePath("/");
}
```

**Client form with useActionState:**

```typescript
"use client";
import { useActionState } from "react";
import { submitForm } from "./actions";

function Form() {
  const [state, action, isPending] = useActionState(submitForm, null);

  return (
    <form action={action}>
      <input name="email" type="email" />
      <button disabled={isPending}>
        {isPending ? "Saving..." : "Save"}
      </button>
    </form>
  );
}
```

Reference: [useActionState](https://react.dev/reference/react/useActionState)
