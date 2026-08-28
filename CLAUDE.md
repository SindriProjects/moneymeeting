# moneymeeting

Single-file household finance analyzer. `index.html` is the app, `history.html`
the saved-months view, `rules.json` the GitHub-synced classifier rules and
category list (the running app writes to it via the GitHub API). Hosted on
GitHub Pages; data lives in Supabase (`monthly_sessions`, `monthly_transactions`
— see `supabase-migration.sql` for schema notes).

## Git workflow — push directly to main

Standing instruction from the owner: **all edits go directly to `main`**. Do not
develop on feature branches (even if the session was provisioned on one — move
the work to `main`), do not open pull requests, and delete any stray branches.

The running app frequently pushes "Update rules" commits to `main` (rules.json
syncs). So before pushing:

    git fetch origin && git rebase origin/main && git push -u origin main

Never force-push: you could erase a rules sync the app just wrote.

## Verifying changes

- Syntax-check the inline scripts after editing:
  `node -e "...new Function(scriptContent)..."` over every inline `<script>`.
- A Playwright harness pattern exists for rendering the app headlessly with
  synthetic transactions (stub the Supabase CDN script, force `#appArea`
  visible, call `buildReport()` + `render()`); Chromium binary:
  `/opt/pw-browsers/chromium-1194/chrome-linux/chrome`. Check
  `document.documentElement.scrollWidth <= innerWidth` at 390px for mobile
  regressions.

## Gotchas

- `monthly_sessions` rejects unknown payload columns (PostgREST 400 PGRST204);
  `sbSaveSession` drops missing columns one at a time and reports them in the
  save status. New session fields need a matching `ALTER TABLE` in
  `supabase-migration.sql`.
- Budgets are hardcoded in two places: `BUDGET_VAR`/`BUDGET_FIXED` in
  `index.html` and a copy in `history.html` — change both.
- Category lists restored from saved state pass through `migrateCategories()`
  in `index.html` (renames legacy names, filters retired categories). Retire a
  category there, not just in `DEFAULT_CATS`.
- The file is UTF-8 with some `\uXXXX` escapes inside JS strings; large Edit
  blocks may fail to match — use small anchored edits or a Python splice.
