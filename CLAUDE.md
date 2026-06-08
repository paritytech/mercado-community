# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**mercado** is a web3 food delivery platform.
Application logic is defined by docs/ folder.

- docs/entities describe business entities, their data and lifecycles
- docs/journeys describe all required user journeys

Use docs/ as a source of truth for all application logic. If I request something that would contradict the docs, point it out and abort.

### apps/web overview

This is the main application for both customer interface and restaurant portal.  
Important code organizational details:

- src/components: these are **presentational** components. They **must** have storybook files present, **must not** use data fetching hooks inside (useState is fine though), and rely solely on props.
- src/containers: these are container components. They **should not** have complex UI inside, can use hooks. Any logic inside the containers should be covered by unit tests, which can rely on hooks mock layer
- src/pages: these are components that represent different routes. Can only be called in `<Route ...`
- src/hooks: these contain react hooks that are the basis of working with data in the application. Currently, each has only a mock implementation, but later should have two: one mock and one real. Mock hooks provide a layer for unit testing containers. Switching between implementations is done by DataContext context

## Development Commands

Use these commands **exclusively** for linting, typechecking and testing

### linting

```sh
pnpm lint # for checking if linting is correct
pnpm format # for fixing the format

```

### typecheck

```sh
pnpm typecheck
```

### tests

```sh
pnpm test:unit # runs unit tests for all packages
pnpm test:e2e # runs e2e tests
```

## Git Workflow

- **Always ask before pushing** - Never push commits without explicit user approval. Batch multiple related changes into a single commit when possible.
- **No Co-Authored-By lines** - Do not include Co-Authored-By lines in commit messages as they break the CLA.

## Patterns to avoid

### Unnecessary ternaries in TSX

Instead of doing this:

```tsx
{
  item.selectedOptions.length > 0 ? (
    <p className="text-xs text-text-tertiary">
      {item.selectedOptions.map((o) => o.name).join(', ')}
    </p>
  ) : null;
}
```

do this:

```tsx
{
  item.selectedOptions.length > 0 && (
    <p className="text-xs text-text-tertiary">
      {item.selectedOptions.map((o) => o.name).join(', ')}
    </p>
  );
}
```

Same goes for ternary for emtpy strings.  
Instead of

```tsx
<span className={`text-xs font-medium`}>
  {isCanceled && canceledBy
    ? ` by ${canceledBy === 'customer' ? 'the customer' : 'the restaurant'}`
    : ''}
</span>
```

do

```tsx
<span className={`text-xs font-medium`}>
  {isCanceled &&
    canceledBy &&
    ` by ${canceledBy === 'customer' ? 'the customer' : 'the restaurant'}`}
</span>
```
