#!/bin/sh
# Developer fallback: start BPMtoOSC on macOS from the repo's .venv (setup: README section "macOS")
cd "$(dirname "$0")" || exit 1

if [ ! -f .venv/bin/activate ]; then
    echo "No .venv found in $(pwd), see the README section \"macOS\" for setup." >&2
    exit 1
fi

. .venv/bin/activate
exec python main_gui.py "$@"
