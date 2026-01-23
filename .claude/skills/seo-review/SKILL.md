---
name: seo-review
description: >
  Perform SEO audit on documentation or content pages. Use before publishing,
  when optimizing underperforming pages, or during content audits.
---

# SEO Review

Audit content pages for search visibility and ranking potential.

## Audit Checklist

### Title Tag (50-60 chars)

- Primary keyword in first half
- Contains compelling hook/benefit
- Not truncated in search results

### Meta Description (150-160 chars)

- Starts with action word (Learn, Discover, Understand)
- Contains primary keyword
- Promises specific value

### Keyword Placement

- In title and meta description
- In first 100 words
- In at least one H2 heading
- No stuffing (max 3-4 per 1000 words)

### Content Structure

- Opens with question hook
- Code/example in first 200 words (for technical content)
- Short paragraphs (2-4 sentences)
- 1,500+ words for comprehensive topics
- Key terms bolded on first mention

### Featured Snippet Optimization

| Query Type | Winning Format |
|------------|----------------|
| "What is X" | 40-60 word definition paragraph |
| "How to X" | Numbered steps |
| "X vs Y" | Comparison table |
| "Types of X" | Bullet list |

### Internal Linking

- 3-5 related page links in body
- Descriptive anchor text (no "click here")
- Related content section at end
- No orphan pages

### Technical SEO

- Single H1 per page (the title)
- URL slug contains keyword, uses hyphens, lowercase
- Page linked from at least one other page

## Scoring

| Category | Points |
|----------|--------|
| Title Tag | /4 |
| Meta Description | /4 |
| Keyword Placement | /5 |
| Content Structure | /6 |
| Featured Snippets | /4 |
| Internal Linking | /4 |
| Technical SEO | /3 |
| **Total** | **/30** |

| Score | Status |
|-------|--------|
| 27-30 | ✅ Ready to publish |
| 23-26 | ⚠️ Minor fixes needed |
| 17-22 | ⚠️ Several improvements needed |
| <17 | ❌ Significant work required |

## Output Format

```markdown
# SEO Audit: [Page Name]

**Score:** X/30 (X%)
**Status:** ✅/⚠️/❌

## Issues

### High Priority
- [Issue]: Current → Recommended

### Medium Priority
- [Issue]: Recommendation

### Low Priority
- [Issue]: Nice to have

## Quick Wins
- [Immediate fixes]
```
