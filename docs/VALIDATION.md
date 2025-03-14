# Documentation and Mermaid Validation Guide

This document explains the validation tools and configuration used in this repository to ensure documentation quality and valid Mermaid diagrams.

## Pre-commit Configuration

We use pre-commit to automatically validate documentation and Mermaid diagrams before changes are committed. The configuration is in `.pre-commit-config.yaml` and includes:

### Documentation Validation

- **markdownlint**: Uses `.markdownlint.yaml` to enforce consistent Markdown styling
- **mdformat**: Automatically formats Markdown files to ensure consistency
- **Other formatting hooks**: Handles whitespace, line endings, and other common issues

### Mermaid Diagram Validation

- **check-mermaid**: A specialized hook that:
  - Extracts Mermaid code blocks from Markdown files
  - Validates the syntax against the Mermaid specification
  - Prevents commits with invalid diagrams

## Installation

To use these validation tools:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks in your local repository
pre-commit install
```

## Manual Validation

You can manually run validation without committing by using:

```bash
# Run the validation script
./validate-docs.sh

# Or run pre-commit manually
pre-commit run --all-files
```

## Mermaid Validation Process

The Mermaid validation works by:

1. Finding all Markdown files with changes
2. Extracting Mermaid code blocks (```mermaid ... ```)
3. Validating each diagram's syntax
4. Reporting any errors with specific details

## Customizing Validation Rules

### Markdown Rules

To modify Markdown linting rules, edit `.markdownlint.yaml`. Current customizations include:

- Line length limits
- Heading styles
- Whitespace rules
- List formatting

### Mermaid Diagram Types

We support all standard Mermaid diagram types, including:

- Flowcharts
- Sequence diagrams
- Class diagrams
- Entity Relationship diagrams
- State diagrams
- Gantt charts

## Troubleshooting

If you encounter validation issues:

1. Read the error message carefully - it will indicate which file and line has problems
2. For Mermaid errors, use [Mermaid Live Editor](https://mermaid.live) to debug
3. For Markdown errors, refer to the [Markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)

## Resources

- [Pre-commit Documentation](https://pre-commit.com/)
- [Mermaid Syntax Documentation](https://mermaid-js.github.io/mermaid/#/)
- [Markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md) 