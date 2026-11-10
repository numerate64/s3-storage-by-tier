    <style id="bmc-support-style">
      .bmc-support {
        display: flex; justify-content: center; align-items: center; box-sizing: border-box; width: 100%;
        margin: 0; padding: 0.55rem 1rem; border-bottom: 1px solid #e0d5bf;
        background: rgba(255, 251, 240, 0.98); color: #5b3a06; text-align: center;
        font: 600 0.9rem/1.4 system-ui, sans-serif;
      }
      .bmc-support a { color: inherit; text-decoration: none; white-space: nowrap; }
      .bmc-support a:hover, .bmc-support a:focus-visible { text-decoration: underline; text-underline-offset: 0.15em; }
      .bmc-support a:focus-visible { outline: 2px solid currentColor; outline-offset: 3px; }
    </style>
<div class="bmc-support"><a href="https://buymeacoffee.com/Caliche" target="_blank" rel="noopener noreferrer">☕ Buy me a coffee</a></div>

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

