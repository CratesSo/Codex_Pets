#!/usr/bin/env bash
set -euo pipefail

pet_id="cow-king"
repo_url="${CODEX_PETS_BASE_URL:-https://raw.githubusercontent.com/CratesSo/Codex_Pets/main}"
pets_root="$HOME/.codex/pets"
install_path="$pets_root/$pet_id"
work_dir="$(mktemp -d)"
new_pet_dir="$work_dir/$pet_id"
trap 'rm -rf "$work_dir"' EXIT

if ! command -v curl >/dev/null 2>&1; then
	echo "Missing required command: curl" >&2
	exit 1
fi

mkdir -p "$new_pet_dir"

curl --retry 3 --retry-delay 1 --connect-timeout 10 -fsSL "$repo_url/pets/$pet_id/pet.json" -o "$new_pet_dir/pet.json"
curl --retry 3 --retry-delay 1 --connect-timeout 10 -fsSL "$repo_url/pets/$pet_id/spritesheet.webp" -o "$new_pet_dir/spritesheet.webp"

if ! grep -Eq '"id"[[:space:]]*:[[:space:]]*"cow-king"' "$new_pet_dir/pet.json"; then
	echo "Downloaded manifest does not look like the $pet_id pet." >&2
	exit 1
fi

mkdir -p "$pets_root"

if [[ -e "$install_path" ]]; then
	backup_path="$install_path.backup.$(date +%Y%m%d%H%M%S)"
	backup_number=1

	while [[ -e "$backup_path" ]]; do
		backup_path="$install_path.backup.$(date +%Y%m%d%H%M%S).$backup_number"
		backup_number=$((backup_number + 1))
	done

	mv "$install_path" "$backup_path"
	echo "Backed up existing $pet_id to $backup_path"
fi

mv "$new_pet_dir" "$install_path"

echo "Installed $pet_id to $install_path"
