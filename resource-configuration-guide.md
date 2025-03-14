# AWS Entity Resolution - Resource Configuration Guide

## Resource Configuration Has Moved

The detailed resource configuration guidelines have been consolidated into the [Implementation Guide](implementation-plan.md) to simplify documentation.

Please refer to the Implementation Guide for comprehensive information on:

1. KMS Key Configuration
2. S3 Bucket Configuration 
3. Glue Database and Table Configuration
4. Entity Resolution Configuration
5. IAM Role Configuration

This consolidation was done to streamline documentation and provide a single reference point for implementation details.

## Key Requirements (Quick Reference)

1. **Same CloudFormation Template**: All resources must be defined in the same CloudFormation template that provisions the Entity Resolution resources
2. **Non-Partitioned Tables**: AWS Entity Resolution does not support partitioned tables
3. **No Lake Formation**: AWS Entity Resolution does not support S3 locations registered with AWS Lake Formation
4. **KMS Key Access**: Entity Resolution service must have access to your KMS keys

## CloudFormation Template Structure

```yaml
Resources:
  # 1. KMS Keys
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

  DataEncryptionKeyAlias:
    Type: AWS::KMS::Alias
    Properties:
      AliasName: !Sub "alias/${AWS::StackName}-er-key"
      TargetKeyId: !Ref DataEncryptionKey

  # 2. S3 Buckets
  InputBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "${AWS::StackName}-er-input-${AWS::AccountId}"
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
              KMSMasterKeyID: !GetAtt DataEncryptionKey.Arn
      LifecycleConfiguration:
        Rules:
          - Id: DeleteAfter30Days
            Status: Enabled
            ExpirationInDays: 30

  OutputBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "${AWS::StackName}-er-output-${AWS::AccountId}"
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
              KMSMasterKeyID: !GetAtt DataEncryptionKey.Arn

  # 3. Glue Resources
  GlueDatabase:
    Type: AWS::Glue::Database
    Properties:
      CatalogId: !Ref AWS::AccountId
      DatabaseInput:
        Name: !Sub "${AWS::StackName}-database"
        Description: Database for Entity Resolution source data

  CustomerTable:
    Type: AWS::Glue::Table
    Properties:
      CatalogId: !Ref AWS::AccountId
      DatabaseName: !Ref GlueDatabase
      TableInput:
        Name: customer_data
        StorageDescriptor:
          Location: !Sub "s3://${InputBucket}/customer-data/"
          InputFormat: org.apache.hadoop.mapred.TextInputFormat
          OutputFormat: org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat
          SerdeInfo:
            SerializationLibrary: org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe
            Parameters:
              'field.delim': ','
          Columns:
            - Name: customer_id
              Type: string
            - Name: first_name
              Type: string
            - Name: last_name
              Type: string
            - Name: email
              Type: string
            - Name: phone
              Type: string

  # 4. Entity Resolution Configuration
  EntityResolutionSchemaMapping:
    Type: AWS::EntityResolution::SchemaMapping
    Properties:
      SchemaName: CustomerSchemaMapping
      MappedInputFields:
        - FieldName: customer_id
          Type: ID
        - FieldName: first_name
          Type: NAME
          SubType: FIRST_NAME
        - FieldName: last_name
          Type: NAME
          SubType: LAST_NAME
        - FieldName: email
          Type: EMAIL
        - FieldName: phone
          Type: PHONE
```

## KMS Key Configuration

### Key Requirements

* Entity Resolution service must have permissions to use your key
* Key policy must allow the necessary KMS actions (Encrypt, Decrypt, GenerateDataKey, etc.)
* Consider enabling automatic key rotation for better security

### Example Key Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "entityresolution.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
```

## S3 Bucket Configuration

### Bucket Requirements

* Input and output buckets should be encrypted with your KMS key
* Consider lifecycle policies for cost management
* Configure appropriate access policies

### Example Input Bucket with Lifecycle Policy

```yaml
InputBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms
            KMSMasterKeyID: !GetAtt DataEncryptionKey.Arn
    LifecycleConfiguration:
      Rules:
        - Id: DeleteAfter30Days
          Status: Enabled
          ExpirationInDays: 30
```

## Glue Table Types

### CSV Data

```yaml
TableInput:
  Name: csv_data
  StorageDescriptor:
    Location: !Sub "s3://${InputBucket}/csv-data/"
    InputFormat: org.apache.hadoop.mapred.TextInputFormat
    OutputFormat: org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat
    SerdeInfo:
      SerializationLibrary: org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe
      Parameters:
        'field.delim': ','
        'serialization.format': ','
    Columns:
      - Name: id
        Type: string
      # Add other columns as needed
```

### JSON Data

```yaml
TableInput:
  Name: json_data
  StorageDescriptor:
    Location: !Sub "s3://${InputBucket}/json-data/"
    InputFormat: org.apache.hadoop.mapred.TextInputFormat
    OutputFormat: org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat
    SerdeInfo:
      SerializationLibrary: org.apache.hive.hcatalog.data.JsonSerDe
    Columns:
      - Name: id
        Type: string
      # Add other columns as needed
```

### Parquet Data

```yaml
TableInput:
  Name: parquet_data
  StorageDescriptor:
    Location: !Sub "s3://${InputBucket}/parquet-data/"
    InputFormat: org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat
    OutputFormat: org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat
    SerdeInfo:
      SerializationLibrary: org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe
    Columns:
      - Name: id
        Type: string
      # Add other columns as needed
```

## Schema Mapping Examples

### Customer Data Schema

| Field | Entity Resolution Type | Description |
|-------|------------------------|-------------|
| customer_id | ID | Unique identifier |
| first_name | NAME (FIRST_NAME) | Customer's first name |
| last_name | NAME (LAST_NAME) | Customer's last name |
| email | EMAIL | Email address |
| phone | PHONE | Phone number |
| address_line1 | ADDRESS (ADDRESS_LINE_1) | Street address |
| city | ADDRESS (CITY) | City |
| state | ADDRESS (STATE) | State/Province |
| zip | ADDRESS (POSTAL_CODE) | Postal/ZIP code |

## Resource Management Best Practices

1. **Naming Convention**: Use consistent resource naming with stack name prefixes
2. **Encryption**: Always encrypt S3 buckets with KMS keys
3. **Lifecycle Policies**: Define appropriate lifecycle policies for cost control
4. **Permissions**: Use least-privilege IAM permissions for all resources
5. **Documentation**: Document your resource configurations for future reference

## Implementation Checklist

- [ ] Define KMS key with proper permissions for Entity Resolution
- [ ] Configure S3 buckets with encryption and lifecycle policies
- [ ] Create Glue database and tables with proper schemas
- [ ] Ensure all resource names/ARNs are correctly referenced
- [ ] Validate IAM permissions for Entity Resolution to access your resources
- [ ] Test the complete template before production use

## Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| **KMS access denied** | Verify KMS key policy includes entityresolution.amazonaws.com service |
| **S3 access denied** | Check bucket policies and IAM role permissions |
| **Glue Table not found** | Verify table was created correctly; check database and table names |
| **Invalid schema mapping** | Ensure field names match between Glue Table and schema mapping |
| **Encryption errors** | Confirm Entity Resolution has permissions to use the KMS key | 