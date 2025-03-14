# Mermaid Diagram Linting

This project uses industry-standard tools for validating Mermaid diagrams in Markdown files through pre-commit hooks.

## Quick Setup

```bash
# Install dependencies
npm install -g @mermaid-js/mermaid-cli
pip install pre-commit

# Set up pre-commit hooks
pre-commit install
```

## Implementation Details

The Mermaid linting solution has the following components:

1. **Pre-commit Configuration** (`.pre-commit-config.yaml`)
   - Uses local hook for Mermaid diagram validation
   - Includes MDFormat for consistent Markdown formatting
   - Integrates with other linting tools

2. **Validation Script** (`validate-mermaid.sh`)
   - Extracts Mermaid diagrams from Markdown files
   - Uses official Mermaid CLI to validate each diagram
   - Reports line numbers and detailed error messages

3. **GitHub Actions Workflow** (`.github/workflows/mermaid-lint.yml`)
   - Runs validation on all Markdown files in CI/CD pipeline
   - Uses the same validation logic as pre-commit
   - Ensures consistent diagram formatting

## Testing

```bash
# Test the validation on sample valid and invalid diagrams
./test/test-mermaid-validation.sh
```

## Manual Validation

```bash
# Validate specific Markdown files
./validate-mermaid.sh file1.md file2.md

# Run pre-commit hooks on all files
pre-commit run --all-files

# Run only Mermaid validation
pre-commit run mermaid-validate --all-files
```

## Common Issues and Solutions

- **Missing Arrows**: Use `-->` instead of `->`
- **Dangling Arrows**: Ensure all arrows connect to nodes
- **Syntax Errors**: Validate using the [Mermaid Live Editor](https://mermaid.live)
- **Installation Issues**: Ensure Node.js 14+ is installed 