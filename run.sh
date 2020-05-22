#!/usr/bin/env bash

# set -x

ENABLE_CONDA=1
ENABLE_VCAM=1

FOMM_CONFIG=fomm/config/vox-adv-256.yaml
FOMM_CKPT=vox-adv-cpk.pth.tar

ARGS=""

while (( "$#" )); do
    case "$1" in
        --no-conda)
            ENABLE_CONDA=0
            shift
            ;;
        --no-vcam)
            ENABLE_VCAM=0
            ARGS="$ARGS --no-stream"
            shift
            ;;
        *|-*|--*)
            ARGS="$ARGS $1"
            shift
            ;;
    esac
done

eval set -- "$ARGS"

kill -9 $(ps aux | grep 'afy/cam_fomm.py' | awk '{print $2}') 2> /dev/null

source scripts/settings.sh

if [[ $ENABLE_VCAM == 1 ]]; then
    bash scripts/create_virtual_camera.sh
fi

if [[ $ENABLE_CONDA == 1 ]]; then
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate $CONDA_ENV_NAME
fi

export PYTHONPATH=$PYTHONPATH:$(pwd):$(pwd)/fomm

python afy/cam_fomm.py \
    --config $FOMM_CONFIG \
    --checkpoint $FOMM_CKPT \
    --cam $CAMID \
    --virt-cam $CAMID_VIRT \
    --relative \
    --adapt_scale \
    $@

