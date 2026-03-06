#!/bin/bash
set -euxo pipefail

export PATH="$HOME/.local/bin:$PATH"

if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

PYTHON_VERSION="${SWESMITH_PYTHON_VERSION:-3.10}"
echo "> Creating uv environment '.venv' with python=${PYTHON_VERSION}"
uv venv --python "${PYTHON_VERSION}" --seed .venv
source .venv/bin/activate

echo "> Installing repo in editable mode"
uv pip install -e .

echo "> Installing test dependencies (extras -> requirements-test.txt -> profile hook)"
if uv pip install -e ".[test]"; then
    echo "> Installed test dependencies via extras [test]"
elif [ -f "requirements-test.txt" ]; then
    uv pip install -r requirements-test.txt
    echo "> Installed test dependencies from requirements-test.txt"
elif [ -n "${SWESMITH_PROFILE_INSTALL_CMDS:-}" ]; then
    echo "> Running profile-provided install_cmds: ${SWESMITH_PROFILE_INSTALL_CMDS}"
    eval "${SWESMITH_PROFILE_INSTALL_CMDS}"
else
    echo "> No explicit test dependency source found; continuing without extra test deps"
fi

if [ -n "${SWESMITH_EXTRA_TEST_DEPS:-}" ]; then
    echo "> Installing extra test deps: ${SWESMITH_EXTRA_TEST_DEPS}"
    uv pip install ${SWESMITH_EXTRA_TEST_DEPS}
fi

echo "> Ensuring pytest available for smoke"
uv pip install pytest
