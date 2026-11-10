<style>
  .bmc-support { position: fixed; top: 12px; right: 12px; z-index: 10000; padding: 8px 12px; border: 1px solid #d8c69f; border-radius: 999px; background: rgba(255, 251, 240, 0.97); box-shadow: 0 2px 10px rgba(23, 32, 38, 0.16); color: #5b3a06; font: 600 0.9rem/1.3 system-ui, sans-serif; text-decoration: none; white-space: nowrap; }
  @media (max-width: 520px) { .bmc-support { left: 50%; right: auto; transform: translateX(-50%); } }
</style>
<a class="bmc-support" href="https://buymeacoffee.com/Caliche" target="_blank" rel="noopener noreferrer">☕ Buy me a coffee</a>

# s3-storage-by-tier

Report Amazon S3 bucket capacity by CloudWatch storage tier from the command line.

The script uses the `AWS/S3` CloudWatch `BucketSizeBytes` metric and prints a simple table with human-readable storage values in MB, GB, or TB.

## Requirements

- Bash
- AWS CLI v2
- AWS credentials with permission to call:
  - `s3:ListAllMyBuckets`
  - `cloudwatch:GetMetricStatistics`

## Usage

Report all buckets in the current AWS account:

```bash
./s3-storage-by-tier.sh
```

Report one bucket:

```bash
./s3-storage-by-tier.sh --bucket my-bucket
```

Use a named AWS profile:

```bash
./s3-storage-by-tier.sh --profile prod --bucket my-bucket
```

## Example Output

```text
Bucket          Storage tier     Used
------          ------------     ----
example-bucket  StandardStorage  1.46 GB
example-bucket  GlacierStorage   3.00 TB
```

## Notes

- S3 bucket storage metrics are daily CloudWatch metrics, not real-time values.
- S3 publishes these bucket storage metrics in `us-east-1`, so the script queries CloudWatch in `us-east-1`.
- Empty or missing storage tiers are omitted from the output.
- Glacier, Intelligent-Tiering, and infrequent access overhead storage types are included when CloudWatch reports them.

## Install

Clone the repo and make sure the script is executable:

```bash
git clone git@github.com:numerate64/s3-storage-by-tier.git
cd s3-storage-by-tier
chmod +x s3-storage-by-tier.sh
```

