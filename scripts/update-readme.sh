#!/usr/bin/env bash
# Regenerate marker-delimited autodoc sections in README.md by calling
# scripts/gen-docs.lua for each section.
#
# Marker format in README.md:
#   <!-- BEGIN:autodoc-<section> -->
#   ...generated content goes here...
#   <!-- END:autodoc-<section> -->
#
# Sections currently supported: keybinds, monitors, rules.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
README="$ROOT/README.md"
GEN="$ROOT/scripts/gen-docs.lua"

if [ ! -f "$README" ]; then
  echo "update-readme: $README not found" >&2
  exit 1
fi

update_section() {
  local section="$1"
  local begin="<!-- BEGIN:autodoc-${section} -->"
  local end="<!-- END:autodoc-${section} -->"

  if ! grep -qF "$begin" "$README"; then
    return 0 # no marker for this section, skip
  fi

  local generated
  generated="$(cd "$ROOT" && lua "$GEN" "$section")"

  local tmp
  tmp="$(mktemp)"
  awk \
    -v begin="$begin" \
    -v end="$end" \
    -v content="$generated" \
    '
      $0 == begin { print; print content; in_block = 1; next }
      $0 == end   { in_block = 0; print; next }
      !in_block   { print }
    ' "$README" > "$tmp"

  if ! cmp -s "$README" "$tmp"; then
    mv "$tmp" "$README"
    echo "update-readme: regenerated autodoc-${section}"
  else
    rm -f "$tmp"
  fi
}

update_section keybinds
update_section monitors
update_section rules
