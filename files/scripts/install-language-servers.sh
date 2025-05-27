#!/usr/bin/env bash
# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail
source ~/.cargo/env 2>/dev/null || true
export PATH="$HOME/.local/bin:$PATH"
export GOPROXY=https://proxy.golang.org,direct
export GOSUMDB=sum.golang.org
export GOTIMEOUT=300sc

echo "Installing bash-language-server..."
sudo npm i -g bash-language-server

echo "Installing dockerfile-language-server-nodejs..."
sudo npm install -g dockerfile-language-server-nodejs

echo "Installing typescript and typescript-language-server..."
sudo npm install -g typescript typescript-language-server

echo "Installing vscode-langservers-extracted..."
sudo npm i -g vscode-langservers-extracted

echo "Installing yaml-language-server@next..."
sudo npm i -g yaml-language-server@next

echo "Installing Go LSP (gopls)..."
go install golang.org/x/tools/gopls@latest                               # LSP

echo "Installing Go debugger (delve)..."
go install github.com/go-delve/delve/cmd/dlv@latest || echo "Warning: Failed to install delve debugger"                      # Debugger
echo "Installing Go formatter (goimports)..."
go install golang.org/x/tools/cmd/goimports@latest                       # Formatter

echo "Installing Go linter language server..."
go install github.com/nametake/golangci-lint-langserver@latest           # Linter

echo "Installing golangci-lint CLI..."
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest # Linter cli

echo "Installing Ruff via UV"
uv tool install ruff@latest

echo "Installing typst lsp"
cargo install --git https://github.com/nvarner/typst-lsp typst-lsp
