# Install UV if you haven't already
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Create project virtual environment
uv venv --python 3.12
uv sync --extra all --extra docs --extra test
