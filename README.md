<div style="position:sticky;top:0;z-index:10000;display:flex;justify-content:center;align-items:center;box-sizing:border-box;width:100%;height:42px;margin:0;padding:0 1rem;background:#172026;color:#fff;text-align:center;font:600 0.9rem/1.4 system-ui,sans-serif"><a href="https://buymeacoffee.com/caliche" target="_blank" rel="noopener noreferrer" style="display:inline-flex;align-items:center;justify-content:center;min-height:30px;padding:4px 12px;border:1px solid #ffde85;border-radius:999px;background:#ffde85;color:#172026;font-weight:700;text-decoration:underline;text-underline-offset:0.15em;white-space:nowrap">☕ Buy me a coffee</a></div>

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

