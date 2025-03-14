# AWS Entity Resolution - Security Guide

## Single Security Requirement: KMS Integration

The only security requirement for AWS Entity Resolution is proper KMS key configuration.

### Why KMS Integration Is Essential

AWS Entity Resolution needs KMS access to:

- Decrypt source data from S3
- Encrypt results in S3
- Protect data during processing

### Minimal KMS Configuration

```yaml
# KMS key policy for Entity Resolution access
Statement:
  - Effect: Allow
    Principal:
      Service: "entityresolution.amazonaws.com"
    Action:
      - "kms:Encrypt"
      - "kms:Decrypt"
      - "kms:ReEncrypt*"
      - "kms:GenerateDataKey*"
      - "kms:DescribeKey"
    Resource: "*"
```

### Testing KMS Access

Verify Entity Resolution has proper KMS access with this simple test:

1. Upload a small test file to your S3 input bucket
1. Run a basic matching workflow
1. Confirm results are written to output bucket

For implementation details, see the [Implementation Guide](implementation-plan.md).
