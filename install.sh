#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${SCRIPT_DIR}/STARNet"
ENV_FILE="${PACKAGE_DIR}/environment-review.yml"
ENV_NAME="starnet"
MANAGER=""

usage() {
  cat <<'EOF'
Usage: bash install.sh [options]

Options:
  --env-name NAME   Conda environment name to create or update (default: starnet)
  --manager NAME    Package manager to use: mamba or conda
  --package-dir DIR STARNet source directory (default: ./STARNet)
  -h, --help        Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-name)
      ENV_NAME="$2"
      shift 2
      ;;
    --manager)
      MANAGER="$2"
      shift 2
      ;;
    --package-dir)
      PACKAGE_DIR="$2"
      ENV_FILE="${PACKAGE_DIR}/environment-review.yml"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${MANAGER}" ]]; then
  if command -v mamba >/dev/null 2>&1; then
    MANAGER="mamba"
  elif command -v conda >/dev/null 2>&1; then
    MANAGER="conda"
  else
    echo "Neither mamba nor conda was found in PATH." >&2
    exit 1
  fi
fi

if [[ ! -d "${PACKAGE_DIR}" ]]; then
  echo "STARNet source directory not found: ${PACKAGE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Pinned environment file not found: ${ENV_FILE}" >&2
  exit 1
fi

echo "Using ${MANAGER} with environment '${ENV_NAME}'"
echo "Package source: ${PACKAGE_DIR}"
echo "Environment file: ${ENV_FILE}"

echo "pip index: using the active pip configuration"
export PIP_RETRIES="${PIP_RETRIES:-10}"
export PIP_TIMEOUT="${PIP_TIMEOUT:-120}"
echo "pip retries: ${PIP_RETRIES}; pip timeout: ${PIP_TIMEOUT}s"

if conda run -n "${ENV_NAME}" python -V >/dev/null 2>&1; then
  echo "Environment '${ENV_NAME}' already exists; updating it from ${ENV_FILE}"
  "${MANAGER}" env update -n "${ENV_NAME}" -f "${ENV_FILE}" --prune
else
  echo "Creating environment '${ENV_NAME}' from ${ENV_FILE}"
  "${MANAGER}" env create -y -n "${ENV_NAME}" -f "${ENV_FILE}"
fi

echo "Installing STARNet in editable mode"
conda run -n "${ENV_NAME}" python -m pip install --no-deps --no-build-isolation -e "${PACKAGE_DIR}"

echo "Verifying STARNet import"
conda run -n "${ENV_NAME}" python -c "import STARNet as ST; print(ST.__file__)"

cat <<EOF

STARNet is installed in the '${ENV_NAME}' environment.

Activate it with:
  conda activate ${ENV_NAME}
EOF
