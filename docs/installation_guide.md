# STARNet Installation Guide

## Prerequisites

STARNet currently supports **Python 3.11** for the validated installation workflow in this repository.

We recommend installing STARNet inside a fresh `conda` or `mamba` environment to avoid dependency conflicts.

### Platform Requirements

STARNet is developed and tested on Linux. macOS and Windows (WSL) may work but are not actively validated.

## Installation Methods

### Quick Install (Recommended)

This repository includes a local installer modeled after OmicVerse's guided install flow, but scoped to the pinned STARNet environment bundled here. It will:

- create or update a dedicated conda environment from `STARNet/environment-review.yml`
- install STARNet in editable mode from the local `STARNet/` source tree
- verify that `import STARNet as ST` succeeds

```bash
bash install.sh
```

By default this creates an environment named `starnet`, uses your existing `conda` and `pip` mirror configuration, and installs the GPU-enabled dependency set defined by `STARNet/environment-review.yml`. The installer sets longer pip retry and timeout values for large GPU wheels. You can override the environment name if needed:

```bash
bash install.sh --env-name starnet-review
```

### Conda / Mamba Installation

If you prefer to run the steps manually, use the pinned environment file directly.

#### Mamba

```bash
mamba env create -n starnet -f STARNet/environment-review.yml
conda run -n starnet python -m pip install --no-deps --no-build-isolation -e STARNet
```

#### Conda

```bash
conda env create -n starnet -f STARNet/environment-review.yml
conda run -n starnet python -m pip install --no-deps --no-build-isolation -e STARNet
```

After either method, activate the environment:

```bash
conda activate starnet
```

This pinned environment is the most stable installation path for users and the preferred workflow for reproducing the tutorial and manuscript environment.

## Usage

After installation, verify that STARNet imports correctly:

```python
import STARNet as ST
```

## Troubleshooting

### pip Mirror / Wheel Download Errors

The STARNet environment installs GPU-enabled PyTorch dependencies, so the download can be large. The quick installer uses your active `pip` configuration. If a local mirror fails with timeout or corrupted gzip responses, retry with an official upstream index:

```bash
PIP_CONFIG_FILE=/dev/null PIP_INDEX_URL=https://pypi.org/simple bash install.sh
```

### libstdc++ / CXXABI Errors

On some systems, the system `libstdc++` may be picked before the active conda environment, causing errors for optional genomics tooling. If this happens, export the active environment library path before running GRN inference:

```bash
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
```

### GPU Support

GPU support is part of the recommended environment because STARNet's GRN workflows depend on GPU-accelerated model components. For optional CuPy acceleration, install the CuPy build matching your CUDA toolkit after STARNet is installed.
