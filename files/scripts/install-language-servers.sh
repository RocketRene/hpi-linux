#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail



sudo npm i -g bash-language-server
sudo npm install -g dockerfile-language-server-nodejs
sudo npm install -g typescript typescript-language-server
sudo npm i -g vscode-langservers-extracted
sudo npm i -g yaml-language-server@next


go install golang.org/x/tools/gopls@latest                               # LSP
go install github.com/go-delve/delve/cmd/dlv@latest                      # Debugger
go install golang.org/x/tools/cmd/goimports@latest                       # Formatter
go install github.com/nametake/golangci-lint-langserver@latest           # Linter
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest # Linter cli



uv tool install ruff@latest

cargo install --git https://github.com/nvarner/typst-lsp typst-lsp
