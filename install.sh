#!/bin/bash
# Instala todas as skills, plugins e programas listados neste repositório.
# Uso: bash install.sh   (ou via curl, no Setup script do ambiente)
BASE="https://raw.githubusercontent.com/jjfjason/minhas-skills/main"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
lista() { if [ -f "$DIR/$1" ]; then cat "$DIR/$1"; else curl -fsSL "$BASE/$1"; fi | grep -v '^\s*#' | grep -v '^\s*$'; }

S=~/.claude/skills; T=$(mktemp -d); mkdir -p "$S"; ok=0; falhas=0
while read -r repo pasta nome; do
  d="$T/${repo//\//_}"
  [ -d "$d" ] || git clone -q --depth 1 "https://github.com/$repo" "$d" 2>/dev/null
  if [ -f "$d/$pasta/SKILL.md" ]; then rm -rf "$S/$nome"; cp -r "$d/$pasta" "$S/$nome"; ok=$((ok+1))
  else echo "FALHOU skill: $nome ($repo/$pasta)"; falhas=$((falhas+1)); fi
done < <(lista skills.txt)
rm -rf "$T"
echo "Skills instaladas: $ok  (falhas: $falhas)"

while read -r ferramenta; do
  npm i -g "$ferramenta" >/dev/null 2>&1 && echo "Programa instalado: $ferramenta" || echo "FALHOU programa: $ferramenta"
done < <(lista npm-tools.txt)

while read -r mkt plugin; do
  claude plugin marketplace add "$mkt" >/dev/null 2>&1
  claude plugin install "$plugin" >/dev/null 2>&1 && echo "Plugin instalado: $plugin" || echo "FALHOU plugin: $plugin"
done < <(lista plugins.txt)
exit 0
