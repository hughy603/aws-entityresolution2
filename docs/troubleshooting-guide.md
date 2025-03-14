# AWS Entity Resolution - Troubleshooting Guide

This guide provides solutions for common issues encountered when implementing and
operating the AWS Entity Resolution Service Catalog product.

## Common Issues and Solutions

### Deployment Issues

| Issue                         | Cause                      | Solution                                                                                |
| ----------------------------- | -------------------------- | --------------------------------------------------------------------------------------- |
| CloudFormation Stack Failure  | Template validation error  | Check CloudFormation events for specific error details and validate template parameters |
|                               | IAM permission issues      | Verify that the deploying role has sufficient permissions to create all resources       |
|                               | Resource limit constraints | Check service quotas and request increases if necessary                                 |
| Service Catalog Access Denied | Insufficient permissions   | Ensure user has ServiceCatalog:\* permissions and access to the portfolio               |
| KMS Key Creation Failure      | KMS key policy error       | Validate key policy syntax and ensure required principals are included                  |

### Security Configuration Issues

| Issue                       | Cause                      | Solution                                                                              |
| --------------------------- | -------------------------- | ------------------------------------------------------------------------------------- |
| KMS Access Denied           | Missing service principal  | Add the entityresolution.amazonaws.com service principal to the KMS key policy        |
|                             | Incorrect key ARN          | Verify the KMS key ARN in the IAM policy matches the actual key ARN                   |
|                             | Cross-account access       | For cross-account scenarios, ensure proper trust relationships are established        |
| S3 Bucket Access Denied     | Bucket policy restrictions | Check bucket policy for conflicts with service access requirements                    |
|                             | Missing bucket permissions | Ensure the service role has s3:GetObject, s3:ListBucket, and s3:PutObject permissions |
| IAM Role Validation Failure | Trust policy issues        | Verify the role trust policy includes the entityresolution.amazonaws.com service      |
|                             | Missing permissions        | Ensure all required permissions are included in the role policy                       |

### Entity Resolution Service Issues

| Issue                     | Cause                          | Solution                                                                  |
| ------------------------- | ------------------------------ | ------------------------------------------------------------------------- |
| Workflow Creation Failure | Schema mapping error           | Validate schema mapping configuration against data source format          |
|                           | Configuration validation error | Check workflow configuration for errors in matching rules or parameters   |
| Schema Mapping Errors     | Field mismatch                 | Ensure field names and types match between schema mapping and actual data |
|                           | Unsupported data type          | Verify that field types are supported by Entity Resolution                |
| Matching Workflow Timeout | Dataset too large              | Split data into smaller batches or adjust processing parameters           |
|                           | Complex matching rules         | Simplify matching rules or use a more efficient combination of rules      |
| Missing Match Results     | Rule configuration too strict  | Review and adjust matching rule parameters to be less restrictive         |
|                           | Data quality issues            | Cleanse and standardize data before processing                            |
| False Positive Matches    | Rules too lenient              | Adjust matching rule thresholds or add additional matching criteria       |
|                           | Duplicate identifiers          | Check for and remove duplicate records in source data                     |

### Performance Issues

| Issue                      | Cause                              | Solution                                                 |
| -------------------------- | ---------------------------------- | -------------------------------------------------------- |
| Slow Workflow Execution    | Large dataset size                 | Split data into smaller batches for parallel processing  |
|                            | Complex matching rules             | Simplify rules or prioritize rules for performance       |
|                            | Resource constraints               | Check for other services competing for resources         |
| High Match Processing Cost | Inefficient workflow configuration | Optimize workflow configuration for resource utilization |
|                            | Unnecessary processing             | Filter input data to only include necessary records      |

## Diagnostic Procedures

### CloudFormation Stack Validation

1. Open the AWS CloudFormation console
1. Select the stack for the Entity Resolution deployment
1. Navigate to the "Events" tab
1. Review events for error messages
1. Check the "Resources" tab to identify which resources failed

### IAM Role Validation

```bash
# List role policies
aws iam list-role-policies --role-name EntityResolutionServiceRole

# Get policy document
aws iam get-role-policy --role-name EntityResolutionServiceRole --policy-name EntityResolutionPolicy

# Verify trust relationship
aws iam get-role --role-name EntityResolutionServiceRole
```

### KMS Key Policy Validation

```bash
# Get key policy
aws kms get-key-policy --key-id <key-id> --policy-name default

# Verify key is accessible by the service
aws kms list-key-policies --key-id <key-id>
```

### S3 Bucket Configuration Validation

```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket <bucket-name>

# Verify encryption settings
aws s3api get-bucket-encryption --bucket <bucket-name>

# Test permissions
aws s3api put-object --bucket <bucket-name> --key test/file.txt --body ./test-file.txt
```

### Entity Resolution Service Validation

```bash
# List schema mappings
aws entityresolution list-schema-mappings

# List matching workflows
aws entityresolution list-matching-workflows

# Check workflow status
aws entityresolution get-matching-job --matching-id <matching-id>
```

## CloudWatch Logs Analysis

1. Navigate to CloudWatch Logs in the AWS Console
1. Look for the following log groups:
   - `/aws/entityresolution/matching-workflows`
   - `/aws/entityresolution/schema-mappings`
1. Filter logs for error messages:
   - `ERROR`
   - `AccessDenied`
   - `ValidationException`
   - `ResourceNotFoundException`

## Performance Optimization Tips

### Data Preparation

- Clean and standardize data before processing
- Remove duplicate records
- Use consistent formatting for key matching fields

### Workflow Configuration

- Start with simple matching rules and add complexity incrementally
- Test with sample data to validate rule effectiveness
- Use ML-based matching for complex scenarios

### Resource Management

- Process data in batches of 1-5GB
- Schedule jobs during off-peak hours
- Monitor CloudWatch metrics for workflow execution

## Support and Escalation

If issues persist after following troubleshooting steps:

1. Gather the following information:

   - CloudFormation stack name
   - Entity Resolution workflow and job IDs
   - Error messages from CloudWatch Logs
   - Steps already taken to troubleshoot

1. Contact AWS Support:

   - Select "Entity Resolution" as the service
   - Provide detailed information about the issue
   - Include timestamps and any correlation IDs from error messages
