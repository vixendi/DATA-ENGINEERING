#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   WORKGROUP=... SECRET_ARN=... DB=dev ./run_redshift_sql.sh /abs/path/to/file.sql
#
# Requirements: aws cli configured, access to redshift-data + secretsmanager

SQL_FILE="${1:-}"
if [[ -z "${SQL_FILE}" || ! -f "${SQL_FILE}" ]]; then
  echo "ERROR: SQL file not found. Usage: $0 /abs/path/to/file.sql" >&2
  exit 2
fi

: "${WORKGROUP:?ERROR: WORKGROUP env var is required}"
: "${SECRET_ARN:?ERROR: SECRET_ARN env var is required}"
DB="${DB:-dev}"

SQL="$(cat "${SQL_FILE}")"

echo "==> Executing: ${SQL_FILE}"
ID="$(
  aws redshift-data execute-statement \
    --workgroup-name "${WORKGROUP}" \
    --database "${DB}" \
    --secret-arn "${SECRET_ARN}" \
    --sql "${SQL}" \
    --query 'Id' --output text
)"

echo "StatementId: ${ID}"

# Poll status
while true; do
  STATUS="$(
    aws redshift-data describe-statement \
      --id "${ID}" \
      --query 'Status' --output text
  )"

  case "${STATUS}" in
    SUBMITTED|PICKED|STARTED|RUNNING)
      sleep 1
      ;;
    FINISHED)
      HAS_RESULT="$(
        aws redshift-data describe-statement \
          --id "${ID}" \
          --query 'HasResultSet' --output text
      )"
      echo "Status: FINISHED (HasResultSet=${HAS_RESULT})"

      if [[ "${HAS_RESULT}" == "True" ]]; then
        aws redshift-data get-statement-result --id "${ID}"
      else
        echo "No result set."
      fi
      break
      ;;
    FAILED|ABORTED)
      ERR="$(
        aws redshift-data describe-statement \
          --id "${ID}" \
          --query 'Error' --output text
      )"
      echo "Status: ${STATUS}"
      echo "Error: ${ERR}" >&2
      exit 1
      ;;
    *)
      echo "Status: ${STATUS}"
      sleep 1
      ;;
  esac
done
