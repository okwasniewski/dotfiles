---
name: nextjs-app-router
description: >
  Next.js 15 App Router patterns.
  Trigger: When working in Next.js App Router (app/), Server Components vs Client Components, Server Actions, Route Handlers, caching/revalidation, and streaming/Suspense.
---

## File Conventions

```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Route UI
├── loading.tsx         # Loading UI (Suspense)
├── error.tsx           # Error boundary
├── not-found.tsx       # 404 page
├── route.ts            # API endpoint
├── template.tsx        # Re-mounted layout
├── default.tsx         # Parallel route fallback
├── (group)/            # Route group (no URL impact)
└── _components/        # Private folder (not routed)
```

## Server Components (Default)

```typescript
// No directive needed - async by default
export default async function Page() {
  const data = await db.query();
  return <Component data={data} />;
}
```

## Client Components

```typescript
'use client'

import { useState, useTransition } from 'react'

export function Button({ action }: { action: () => Promise<void> }) {
  const [isPending, startTransition] = useTransition()

  return (
    <button onClick={() => startTransition(action)} disabled={isPending}>
      {isPending ? 'Loading...' : 'Click'}
    </button>
  )
}
```

Use `'use client'` when: useState, useEffect, event handlers, browser APIs.

## Server Actions

```typescript
// app/actions.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string
  await db.users.create({ data: { name } })
  revalidatePath('/users')
  redirect('/users')
}

// Usage
<form action={createUser}>
  <input name="name" required />
  <button type="submit">Create</button>
</form>
```

## Data Fetching

```typescript
// Parallel fetching
async function Page() {
  const [users, posts] = await Promise.all([getUsers(), getPosts()])
  return <Dashboard users={users} posts={posts} />
}

// Streaming with Suspense
<Suspense fallback={<Skeleton />}>
  <SlowComponent />
</Suspense>
```

## Caching

```typescript
fetch(url, { cache: 'no-store' })           // Always fresh
fetch(url, { cache: 'force-cache' })        // Static
fetch(url, { next: { revalidate: 60 } })    // ISR
fetch(url, { next: { tags: ['products'] } }) // Tag-based
```

## Route Handlers

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const users = await db.users.findMany()
  return NextResponse.json(users)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const user = await db.users.create({ data: body })
  return NextResponse.json(user, { status: 201 })
}
```

## Parallel Routes

```typescript
// app/dashboard/layout.tsx
export default function Layout({
  children,
  analytics,
  team,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  team: React.ReactNode
}) {
  return (
    <div>
      <main>{children}</main>
      <aside>{analytics}</aside>
      <aside>{team}</aside>
    </div>
  )
}

// app/dashboard/@analytics/page.tsx
// app/dashboard/@team/page.tsx
```

## Intercepting Routes (Modal)

```
app/
├── @modal/(.)photos/[id]/page.tsx  # Intercept
├── photos/[id]/page.tsx            # Full page
└── layout.tsx                      # Renders {modal} slot
```

## Middleware

```typescript
// middleware.ts (root level)
import { NextResponse, type NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  return NextResponse.next()
}

export const config = { matcher: ['/dashboard/:path*'] }
```

## Metadata

```typescript
// Static
export const metadata = {
  title: { default: 'App', template: '%s | App' },
  description: 'Description',
}

// Dynamic
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params
  const product = await getProduct(id)
  return { title: product.name }
}
```

## server-only

```typescript
import 'server-only'

// Errors if imported in client component
export async function getSecretData() {
  return db.secrets.findMany()
}
```

## Best Practices

**Do:**
- Start with Server Components, add `'use client'` only when needed
- Colocate data fetching where it's used
- Use Suspense for streaming slow data
- Use Server Actions for mutations

**Don't:**
- Use hooks in Server Components
- Fetch data in Client Components (use Server Components or React Query)
- Over-nest layouts
- Forget loading states
