# AWS Entity Resolution - Implementation Guide

This guide provides a streamlined approach to implementing the AWS Entity Resolution
Service Catalog product.

## Implementation Workflow

```mermaid
graph LR
    A[Plan] --> B[Develop]
    B --> C[Test]
    C --> D[Deploy]
```

## Implementation Checklist

### 1. Planning & Requirements

- [ ] Define entity resolution use case and requirements
- [ ] Identify data sources and format requirements
- [ ] Plan S3 bucket structure and KMS key configuration

### 2. CloudFormation Development

- [ ] Develop base CloudFormation template
- [ ] Define and configure KMS key for Entity Resolution access
- [ ] Define S3 input and output buckets with encryption
- [ ] Create schema mapping templates
- [ ] Configure IAM roles

### 3. Testing & Validation

- [ ] Test template deployment
- [ ] Verify KMS key permissions
- [ ] Test entity resolution workflows with sample data

### 4. Deployment

- [ ] Publish to Service Catalog
- [ ] Create documentation for users
- [ ] Set up support processes

## Sample Data Format

Below is an example of correctly formatted data for Entity Resolution:

```csv
customer_id,first_name,last_name,email,phone
C001,John,Smith,john.smith@example.com,555-123-4567
C002,Jane,Doe,jane.doe@example.com,555-987-6543
```

Entity Resolution can process this data when properly mapped in your schema
configuration.

## Resource Configuration Guide

### KMS Key Configuration

A single KMS key is essential for encrypting your data. Entity Resolution needs access
to this key.

```yaml
DataEncryptionKey:
  Type: AWS::KMS::Key
  Properties:
    Description: "KMS key for encrypting Entity Resolution data"
    EnableKeyRotation: true
    KeyPolicy:
      Version: "2012-10-17"
      Statement:
        - Effect: Allow
          Principal:
            AWS: !Sub "arn:aws:iam::${AWS::AccountId}:root"
          Action: "kms:*"
          Resource: "*"
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

### S3 Bucket Configuration

S3 buckets store your source data and entity resolution results.

```yaml
InputBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms
            KMSMasterKeyID: !GetAtt DataEncryptionKey.Arn

OutputBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms
            KMSMasterKeyID: !GetAtt DataEncryptionKey.Arn
```

### IAM Role Configuration

A simple IAM role for Entity Resolution with only the required permissions:

```yaml
EntityResolutionRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: "2012-10-17"
      Statement:
        - Effect: Allow
          Principal:
            Service: entityresolution.amazonaws.com
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - !Sub "arn:${AWS::Partition}:iam::aws:policy/AmazonS3ReadOnlyAccess"
    Policies:
      - PolicyName: EntityResolutionS3WriteAccess
        PolicyDocument:
          Version: "2012-10-17"
          Statement:
            - Effect: Allow
              Action:
                - s3:PutObject
                - s3:PutObjectAcl
              Resource: !Sub "arn:aws:s3:::${OutputBucket}/*"
```

### Entity Resolution Configuration

Configure the Entity Resolution workflow to match your specific needs:

```yaml
EntityResolutionWorkflow:
  Type: AWS::EntityResolution::MatchingWorkflow
  Properties:
    Description: "Customer matching workflow"
    InputSourceConfig:
      InputSourceARN: !Sub "arn:aws:s3:::${InputBucket}/customer-data/"
    OutputSourceConfig:
      OutputS3Path: !Sub "s3://${OutputBucket}/matching-results/"
      KMSArn: !GetAtt DataEncryptionKey.Arn
    RoleArn: !GetAtt EntityResolutionRole.Arn
    ResolutionTechniques:
      ResolutionType: "RULE_MATCHING"
      RuleBasedProperties:
        Rules:
          - MatchingKeys:
              - "email"
            Rule: "Exact"
          - MatchingKeys:
              - "first_name"
              - "last_name"
              - "phone"
            Rule: "Exact"
```

## Common Challenges & Solutions

| Challenge              | Solution                                                        |
| ---------------------- | --------------------------------------------------------------- |
| **KMS Access Denied**  | Verify Entity Resolution is allowed in your key policy          |
| **Data Format Issues** | Ensure data in S3 is in a compatible format (CSV/JSON)          |
| **Schema Mapping**     | Ensure field names match between source data and schema mapping |

## Required Permissions

Users deploying this Service Catalog product need:

```
servicecatalog:ProvisionProduct
cloudformation:CreateStack
s3:CreateBucket
kms:CreateKey
iam:PassRole
```

## Next Steps After Deployment

1. Verify CloudFormation stack created successfully
1. Confirm S3 buckets are properly configured with encryption
1. Test data upload and processing workflow
1. Monitor initial matching results and refine as needed
