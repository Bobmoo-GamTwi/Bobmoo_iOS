---
name: linear-github-issue-sync
description: Create Linear and GitHub issues together with the same core content, shared convention, and cross-links.
---

# Linear + GitHub Issue Sync

## When to Use

- User asks to create a Linear issue and GitHub issue at the same time.
- User asks to keep Linear/GitHub issue content synchronized at creation time.

## Required Convention

### Title

- Always normalize to: `[Prefix] <what to do>`
- Prefix set: `Feature`, `Bug`, `Refactor`, `Chore`, `Docs`, `Test`

### Body Template

Use this base template for both Linear and GitHub issue bodies:

```markdown
## 📝 작업 페이지 캡쳐
|    페이지    |   캡쳐   |
| :-------------: | :----------: |
| 피그마 | <img src = "" width ="250"> 

## ✔️ To-Do
- [ ] 세부적으로 적어주세요
```

If the user provides details/checklist, replace the default To-Do item with concrete items and append extra details below.

## Linear Defaults (must apply)

- Assignee: `me`
- State: `Todo`
- Priority: infer automatically, but always set explicit numeric value (`1|2|3|4`)
- Labels: infer automatically, but always set at least one explicit label
- Due date:
  - user-specified date if provided
  - otherwise today (`YYYY-MM-DD`, user timezone)

## GitHub Defaults (must apply)

- Repository: use current repo by default (`gh repo view`), unless user specifies another repo.
- Labels: map from inferred category and apply at least one label. If missing, create label first then apply.
- Assignee: assign `@me` when permission/repo policy allows; if not, proceed without failing.
- Milestone/project: set only when user explicitly asks.

## Sync Execution Flow

1. Normalize title to convention.
2. Build canonical body using template.
3. Create Linear issue first with Linear defaults.
4. Create GitHub issue with same title/body.
5. Cross-link both sides:
   - Add `GitHub: <url>` to Linear issue description.
   - Add `Linear: <url>` to GitHub issue body (or as first comment if body update is restricted).
6. Return both identifiers/URLs in one response.
7. Do not proceed to implementation/PR workflow until both URLs are confirmed and visible.

## Priority and Label Heuristic

Priority mapping (Linear):

- `1 Urgent`: outage, security incident, data loss, release blocker
- `2 High`: major user impact, deadline-critical
- `3 Medium`: normal task (default)
- `4 Low`: cleanup/nice-to-have

Label mapping candidates (both systems when available):

- bug/fix/error/crash -> `bug`
- feature/implement/add -> `feature`
- refactor/cleanup -> `refactor`
- test/qa -> `test`
- docs/readme -> `documentation`
- perf/slow -> `performance`
- security/auth/vulnerability -> `security`

Fallbacks when inference is weak:

- Priority fallback: `3 (Medium)`
- Label fallback: `Chore` (if unavailable, `Feature`)

## Failure Handling

- If Linear succeeds and GitHub fails:
  - keep Linear issue open
  - comment on Linear with `GitHub creation failed` reason
  - report partial success clearly
  - block implementation/PR start until GitHub issue is created and cross-linked
- If GitHub succeeds and Linear fails:
  - comment on GitHub with `Linear creation failed` reason
  - report partial success clearly
  - block implementation/PR start until Linear issue is created and cross-linked
- Never silently fail one side.
- Never omit priority/labels silently. If setting fails, report explicit reason and retry once with fallback values.

## Response Format

Always return:

- Linear: identifier, URL, state, assignee, priority, labels, due date
- GitHub: issue number, URL, assignee, labels
- Sync status: `full success` or `partial success` with failure reason
