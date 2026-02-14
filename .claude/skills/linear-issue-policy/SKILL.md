---
name: linear-issue-policy
description: Enforces Linear MCP issue creation defaults: state TODO, assignee to the current user, smart priority/labels, and due date policy (user date or today).
---

# Linear Issue Policy

## When to Use

- User asks to create a Linear issue/ticket/task.
- User asks to file a bug/task/chore into Linear via MCP.

If user explicitly references an existing Linear issue key (for example `BOB-123`) and asks `작업 준비`, do not create a new Linear issue. Reuse that issue and hand over to `linear-github-issue-sync` flow for GitHub issue/link preparation.

## Required Policy

When creating a Linear issue, apply all rules below.

1. Set assignee to the current authenticated user ("me").
2. Set state to `Todo`.
3. Determine priority from context (impact, urgency, risk).
4. Determine and apply relevant labels from title/body context.
5. Set due date:
   - If user specifies a date, use it.
   - If not specified, set due date to today in the user's timezone.

## Title Convention (Mandatory)

Use this title format for every new issue:

- `[Prefix] <what to do>`

Examples:

- `[Feature] 로그인 화면 개선`
- `[Bug] 결제 실패 에러 수정`
- `[Refactor] 네트워크 레이어 정리`

Prefix suggestion map:

- `Feature`, `Bug`, `Refactor`, `Chore`, `Docs`, `Test`

If user gives a title that does not match the format, normalize it before creating the issue.

## Issue Body Template (from `.github/ISSUE_TEMPLATE/issue_template.md`)

Use this structure in the Linear issue description:

```markdown
## 📝 작업 페이지 캡쳐
|    페이지    |   캡쳐   |
| :-------------: | :----------: |
| 피그마 | <img src = "" width ="250"> 

## ✔️ To-Do
- [ ] 세부적으로 적어주세요
```

Template rules:

- Keep both sections (`작업 페이지 캡쳐`, `To-Do`) in the body.
- If user provides extra details, append them below the template.
- If user provides checklist items, replace the default To-Do line with concrete items.

## Execution Checklist

1. Identify target team/project from user message or context.
2. Resolve current user (viewer/me) and use as assignee.
3. Resolve the team's workflow states and find `Todo` state.
4. Build issue payload with:
   - team
   - title
   - description (must follow the issue template above)
   - assignee (me)
   - state (`Todo`)
   - priority (auto-judged, explicit `1|2|3|4` value required)
   - labels (auto-judged, at least one label required)
   - dueDate (user date or today)
5. Create issue and return identifier + URL + state + assignee + due date.

## Priority Heuristic

Use this default mapping when user did not explicitly set priority:

- `Urgent (1)`: production outage, data loss, security incidents, release blockers.
- `High (2)`: major user-facing breakage, high business impact, near-term deadline.
- `Medium (3)`: standard feature/chore with regular impact.
- `Low (4)`: minor improvements, cleanup, nice-to-have.

If evidence is weak, default to `Medium (3)`.

## Label Heuristic

Infer labels from title/body keywords and existing team taxonomy. Prefer existing labels over creating new ones unless needed.

Common mappings:

- bug/fix/error/crash -> `bug`
- feature/implement/add -> `feature`
- refactor/cleanup -> `refactor`
- test/qa -> `test`
- docs/readme -> `documentation`
- perf/slow -> `performance`
- security/auth/vulnerability -> `security`

If confidence is low, fallback label is `Chore` (or `Feature` if `Chore` is unavailable).

## Date Policy

- User-specified date always wins.
- If no date is provided, set due date to today's local date (`YYYY-MM-DD`).

## Response Format

Always include:

- Issue identifier
- Issue URL
- Team
- State (must be `Todo`)
- Assignee (me)
- Priority
- Labels
- Due date

## Guardrails

- Do not leave assignee empty unless user explicitly asks for unassigned.
- Do not leave state as `Backlog`.
- Do not skip due date.
- Do not omit priority.
- Do not omit labels.
- If `Todo` state does not exist, pick the closest planned state and mention fallback explicitly.
- If user specified an existing Linear issue key for `작업 준비`, never create a duplicate Linear issue.
