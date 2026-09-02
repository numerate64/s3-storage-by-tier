#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  s3-storage-by-tier.sh [--bucket BUCKET_NAME] [--profile AWS_PROFILE]

Examples:
  ./s3-storage-by-tier.sh
  ./s3-storage-by-tier.sh --bucket my-bucket
  ./s3-storage-by-tier.sh --profile prod --bucket my-bucket

Notes:
  - Uses CloudWatch metric AWS/S3 BucketSizeBytes.
  - S3 storage metrics are daily, not real-time.
  - CloudWatch S3 bucket storage metrics are queried in us-east-1.
  - Output is formatted for CLI reading. Pipe through sed/awk if you need CSV.
EOF
}

BUCKET=""
PROFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bucket|-b)
      BUCKET="${2:-}"
      [[ -n "$BUCKET" ]] || { echo "Missing value for --bucket" >&2; exit 2; }
      shift 2
      ;;
    --profile|-p)
      PROFILE="${2:-}"
      [[ -n "$PROFILE" ]] || { echo "Missing value for --profile" >&2; exit 2; }
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

AWS_ARGS=(--region us-east-1)
if [[ -n "$PROFILE" ]]; then
  AWS_ARGS+=(--profile "$PROFILE")
fi

STORAGE_TYPES=(
  StandardStorage
  StandardIAStorage
  StandardIASizeOverhead
  StandardIAObjectOverhead
  OneZoneIAStorage
  OneZoneIASizeOverhead
  IntelligentTieringFAStorage
  IntelligentTieringIAStorage
  IntelligentTieringAIAStorage
  IntelligentTieringAAStorage
  IntelligentTieringDAAStorage
  GlacierInstantRetrievalStorage
  GlacierIRSizeOverhead
  GlacierStorage
  GlacierObjectOverhead
  GlacierS3ObjectOverhead
  GlacierStagingStorage
  DeepArchiveStorage
  DeepArchiveObjectOverhead
  DeepArchiveS3ObjectOverhead
  DeepArchiveStagingStorage
  ReducedRedundancyStorage
  ExpressOneZoneStorage
)

START_TIME="$(date -u -d '3 days ago' +%Y-%m-%dT%H:%M:%SZ)"
END_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

get_buckets() {
  if [[ -n "$BUCKET" ]]; then
    printf '%s\n' "$BUCKET"
  else
    aws s3api list-buckets \
      "${AWS_ARGS[@]}" \
      --query 'Buckets[].Name' \
      --output text | tr '\t' '\n'
  fi
}

get_bucket_tier_bytes() {
  local bucket="$1"
  local storage_type="$2"

  aws cloudwatch get-metric-statistics \
    "${AWS_ARGS[@]}" \
    --namespace AWS/S3 \
    --metric-name BucketSizeBytes \
    --dimensions "Name=BucketName,Value=${bucket}" "Name=StorageType,Value=${storage_type}" \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --period 86400 \
    --statistics Average \
    --query 'Datapoints | sort_by(@,&Timestamp)[-1].Average' \
    --output text
}

human_size() {
  local bytes="$1"

  awk -v bytes="$bytes" '
    BEGIN {
      mb = bytes / 1024 / 1024
      gb = mb / 1024
      tb = gb / 1024

      if (tb >= 1) {
        printf "%.2f TB", tb
      } else if (gb >= 1) {
        printf "%.2f GB", gb
      } else {
        printf "%.2f MB", mb
      }
    }
  '
}

print_report() {
  {
    printf 'Bucket\tStorage tier\tUsed\n'
    printf -- '------\t------------\t----\n'

    while IFS= read -r bucket; do
      [[ -n "$bucket" ]] || continue

      for storage_type in "${STORAGE_TYPES[@]}"; do
        bytes="$(get_bucket_tier_bytes "$bucket" "$storage_type")"

        if [[ "$bytes" == "None" || -z "$bytes" ]]; then
          continue
        fi

        printf '%s\t%s\t%s\n' "$bucket" "$storage_type" "$(human_size "$bytes")"
      done
    done < <(get_buckets)
  }
}

if command -v column >/dev/null 2>&1; then
  print_report | column -t -s $'\t'
else
  print_report
fi
