#!/usr/bin/env bash
# Revisa que no se publique nada que no debe estar en el repositorio.
#
# Uso:
#   scripts/check-repo.sh --staged   revisa lo que está en el área de preparación (lo usa el hook pre-commit)
#   scripts/check-repo.sh --all      revisa todos los archivos versionados (lo usa GitHub Actions)
#
# Termina con código 0 si no encuentra problemas y 1 si encuentra alguno.
# Palabras prohibidas propias (por ejemplo, nombres o códigos que no deben aparecer): una por línea
# en privado/palabras-prohibidas.txt. Ese archivo nunca se sube, así que esta revisión solo corre
# en tu computador.

set -u
mode="${1:---staged}"
root="$(git rev-parse --show-toplevel)"
cd "$root" || exit 1

# Este script y el workflow contienen los patrones a propósito: no se revisa su contenido.
self_files='^(scripts/check-repo\.sh|\.github/workflows/check-repo\.yml)$'

if [ "$mode" = "--staged" ]; then
  files=$(git diff --cached --name-only --diff-filter=ACMR)
  content() { git show ":$1" 2>/dev/null; }
  size() { git cat-file -s ":$1" 2>/dev/null || echo 0; }
elif [ "$mode" = "--all" ]; then
  files=$(git ls-files)
  content() { cat -- "$1" 2>/dev/null; }
  size() { wc -c < "$1" 2>/dev/null || echo 0; }
else
  echo "Uso: $0 --staged | --all" >&2
  exit 2
fi

problems=0
report() { echo "  ✗ $1: $2"; problems=$((problems + 1)); }

forbidden_paths='^(reference|privado|build)/|\.paclet$|(^|/)\.env($|\.)|\.pem$|\.key$|(^|/)mathpass$'
secret_patterns='-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-ant-[A-Za-z0-9_-]{10,}|AKIA[0-9A-Z]{16}'
password_pattern='(password|passwd|api[_-]?key|secret)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{6,}'
email_pattern='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
words_file="privado/palabras-prohibidas.txt"

while IFS= read -r f; do
  [ -z "$f" ] && continue

  if echo "$f" | grep -qE "$forbidden_paths"; then
    report "$f" "esta ruta no se publica (reference/, privado/, build/, paclets, claves o licencias)"
    continue
  fi

  bytes=$(size "$f")
  if [ "${bytes:-0}" -gt 1048576 ]; then
    report "$f" "pesa más de 1 MB ($bytes bytes)"
  fi

  echo "$f" | grep -qE "$self_files" && continue

  text=$(content "$f")

  if echo "$text" | grep -qE -- "$secret_patterns"; then
    report "$f" "parece contener una clave o token"
  fi
  if echo "$text" | grep -qiE -- "$password_pattern"; then
    report "$f" "parece contener una contraseña o clave escrita en el archivo"
  fi
  if echo "$text" | grep -qE '/home/[a-z_][a-z0-9_-]*/'; then
    report "$f" "contiene una ruta personal (/home/usuario/...)"
  fi
  if echo "$text" | grep -oE "$email_pattern" | grep -qviE 'noreply'; then
    report "$f" "contiene un correo que no es noreply"
  fi
  case "$f" in
    *.nb)
      if echo "$text" | grep -qE '"(Output|Print|Message)"'; then
        report "$f" "notebook con salidas: usa Cell > Delete All Output antes de guardarlo"
      fi ;;
  esac
  if [ -r "$words_file" ] && grep -qvE '^[[:space:]]*(#|$)' "$words_file"; then
    if echo "$text" | grep -qiF -f <(grep -vE '^[[:space:]]*(#|$)' "$words_file"); then
      report "$f" "contiene una palabra de $words_file"
    fi
  fi
done <<< "$files"

if [ "$problems" -gt 0 ]; then
  echo ""
  echo "Revisión del repositorio: $problems problema(s). Corrígelos antes de continuar."
  echo "Si estás seguro de que es un falso positivo, coméntalo antes de saltarte la revisión."
  exit 1
fi
echo "Revisión del repositorio: sin problemas."
exit 0
