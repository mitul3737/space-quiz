#!/usr/bin/env bash
# Devin API helper for the Space Quiz workshop.
# Usage:
#   ./devin.sh create "prompt"
#   ./devin.sh list
#   ./devin.sh msg SESSION_ID "message"
#   ./devin.sh note
set -euo pipefail
: "${DEVIN_API_KEY:?Run: export DEVIN_API_KEY=cog_...}"
: "${DEVIN_ORG_ID:?Run: export DEVIN_ORG_ID=...}"

API="https://api.devin.ai/v3/organizations/$DEVIN_ORG_ID"
AUTH=(-H "Authorization: Bearer $DEVIN_API_KEY" -H "Content-Type: application/json")

case "${1:-}" in
  create)
    curl -s -X POST "$API/sessions" "${AUTH[@]}" \
      -d "$(jq -n --arg p "$2" '{prompt: $p}')" | jq .
    ;;
  list)
    curl -s "$API/sessions" "${AUTH[@]}" | jq .
    ;;
  msg)
    curl -s -X POST "$API/sessions/$2/messages" "${AUTH[@]}" \
      -d "$(jq -n --arg m "$3" '{message: $m}')" | jq .
    ;;
  note)
    curl -s -X POST "$API/knowledge/notes" "${AUTH[@]}" \
      -d '{"name":"Space Quiz rules","trigger":"When working on space-quiz","body":"Single index.html, no dependencies, keep light and dark themes, respect prefers-reduced-motion, keyboard accessible."}' | jq .
    ;;
  *)
    echo "usage: $0 create \"prompt\" | list | msg SESSION_ID \"message\" | note"
    exit 1
    ;;
esac
