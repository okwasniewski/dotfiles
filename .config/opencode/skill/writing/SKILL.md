---
name: writing
description: >
  Write technical blog posts in Oskar's style. Use for drafting tutorials,
  guides, or technical content. Focuses on React Native, iOS, and spatial
  computing topics.
---

# Writing Style Guide

Technical blog posts with practical, tutorial-based approach.

## Structure

Every post follows this pattern:

1. **Title** — Clear, specific (e.g., "Creating a macOS MenuBar app with React Native")
2. **Subtitle** — Short phrase expanding on title
3. **Contents** — Table of contents with anchor links
4. **Introduction** — 2-3 paragraphs setting context
5. **Main sections** — Step-by-step with code
6. **Closing** — "That's all" or "That's a wrap" section

## Tone & Voice

- **Direct and practical** — Get to the point quickly
- **First person plural** — "we will", "let's", not "I will show you"
- **Conversational but technical** — No fluff, but friendly
- **Confident** — State things directly without hedging

## Section Headers

Use descriptive, action-oriented headers:

**Good:**
```
## Getting started
## Setup your project
## Adding second window
## Common issues
## Handling window resizing
```

**Avoid:**
```
## Step 1: Setup
## How to do X
## The X section
```

## Introduction Pattern

1. Set context for why this matters
2. Brief explanation of what we'll build/learn
3. Optional: Link to related content or prerequisites

Example:
> MenuBar apps allows users to quickly access apps content wherever they are in the operating system. They can work as an extension of your app... In this article we will discuss three different ways of creating menubar **only** app.

## Code Blocks

- **Always include filename** above code blocks when applicable
- **Add context** before code with brief explanation
- **Use syntax highlighting** with language specified
- **Keep snippets focused** — show relevant parts, not entire files

Format:
```
AppDelegate.mm

\`\`\`objc
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  // code here
}
\`\`\`
```

## Tips & Notes

Use emoji callouts for tips:

```
💡 `xcrun` is a command line tool shipped with Xcode.

**Note:** Keep in mind that you will need to have Xcode installed.

**Warning:** XR API doesn't store information whether session is open.
```

## Transitions Between Sections

- "Next, let's..." or "Next let's..."
- "First, let's..." or "Firstly, let's..."
- "In order to..."
- "Now it's time to..."
- "Let's start with..."

## Closing Section

Always titled "That's all" or "That's a wrap":

```
## That's all

Thanks for reading! I hope you found this article useful. If you have any questions or feedback feel free to reach out to me on [Twitter](https://twitter.com/o_kwasniewski).

For those interested in the sample code, you can find it in the [GitHub Repository](link).
```

## Links & References

- Link to external resources naturally within text
- For libraries: link to GitHub repo
- For concepts: link to official docs or WWDC talks
- Include code repository link at the end if applicable

## Personal Voice Elements

- Use "we" when walking through steps together
- Use "you" when addressing reader's situation
- Occasional embedded tweets for quick tips
- Reference own tools/libraries when relevant (e.g., Minisim, react-native-menubar-extra)

## Disclaimers

Place disclaimers clearly when needed:

```
*Disclaimer: This blog post assumes you have basic iOS development knowledge.*
```

## Length Guidelines

- **Introduction:** 2-3 short paragraphs
- **Sections:** Vary based on complexity
- **Code blocks:** Focused, with key parts highlighted
- **Total:** 800-1500 words typical

## Non-Technical Posts

For product/personal posts (like NoteScan):

- More personal "I" voice
- Focus on problem → solution narrative
- Include workflow/usage examples
- End with call-to-action or question to reader

Example closing:
> *What's your analog workflow? Find me on [X](https://x.com/okwasniewski)*.
