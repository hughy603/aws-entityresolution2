# Mermaid Diagram Linting

This repository includes a comprehensive linting solution for Mermaid diagrams in Markdown files.

## Features

- **Syntax Validation**: Validates all Mermaid diagrams against the official Mermaid parser
- **Pre-commit Integration**: Prevents commits with invalid Mermaid diagrams
- **Detailed Error Reporting**: Shows line numbers and specific syntax issues
- **Basic Validation Fallback**: Provides additional checks when the parser fails
- **CI/CD Ready**: Can be integrated into CI/CD pipelines

## Setup

1. Ensure you have Node.js 14+ and npm installed
2. Install pre-commit: `pip install pre-commit`
3. Install the pre-commit hooks: `pre-commit install`
4. Install Node.js dependencies: `npm install`

## Usage

### Manual Linting

```bash
# Using the convenience script
./lint-mermaid.sh

# Or directly with npm
npm run lint

# Or with the Node.js script directly
node mermaid-lint.js
```

### Pre-commit Hooks

The linters run automatically when you commit changes if you've installed pre-commit hooks.

## How It Works

1. The pre-commit hook runs on all Markdown files in the repository
2. Extracts Mermaid diagrams from those files (code blocks that start with \```mermaid)
3. Validates each diagram using the official Mermaid parser
4. Reports errors with line numbers and suggestions for fixing

## Available Linting Tools

1. **Custom Node.js Linter** (`mermaid-lint.js`): Uses the official Mermaid parser to validate diagrams and provide detailed error messages.
2. **Pre-commit Mermaid Hook** (`pre-commit-mermaid`): A specialized pre-commit hook for validating Mermaid diagrams.
3. **MDFormat Mermaid Plugin**: Formats Mermaid diagrams in Markdown files.

## Common Errors and Fixes

| Error | Fix |
|-------|-----|
| Missing arrows | Ensure all connections use `-->` instead of `->` |
| Dangling arrows | Make sure each arrow connects to a node |
| Missing direction | Add direction (TB, TD, BT, RL, LR) to flowcharts |
| Syntax errors | Check the Mermaid syntax documentation |

## Integration with CI/CD

This linting setup can be integrated with CI/CD pipelines to ensure all Mermaid diagrams are valid before merging.

```yaml
# Example GitHub Actions workflow
name: Lint Mermaid Diagrams

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '16'
      - run: npm install
      - run: node mermaid-lint.js
```

## Additional Resources

- [Mermaid Syntax Documentation](https://mermaid-js.github.io/mermaid/#/)
- [Pre-commit Documentation](https://pre-commit.com/) 