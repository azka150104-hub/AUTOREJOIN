#!/data/data/com.termux/files/usr/bin/bash
# Roblox Rejoin Menu for Termux
# Launcher untuk place Roblox yang Anda kelola sendiri.
# Tidak memakai executor, injection, atau bypass Roblox.

set -u

CONFIG_DIR="${HOME}/.config/roblox-rejoin-menu"
CONFIG_FILE="${CONFIG_DIR}/config.conf"
PLACE_ID=""
REFRESH_SECONDS=90
PROJECT_DIR="$PWD"
MANUAL_APP_PACKAGE=""

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
WHITE='\033[0;37m'
RESET='\033[0m'

load_config() {
  local key value
  [[ -f "$CONFIG_FILE" ]] || return

  # Baca hanya nilai konfigurasi yang diharapkan; jangan menjalankan isi konfigurasi.
  while IFS='=' read -r key value; do
    case "$key" in
      PLACE_ID)
        [[ "$value" =~ ^[0-9]+$ ]] && PLACE_ID="$value"
        ;;
      REFRESH_SECONDS)
        [[ "$value" =~ ^[0-9]+$ ]] && (( value >= 30 )) && REFRESH_SECONDS="$value"
        ;;
      MANUAL_APP_PACKAGE)
        [[ "$value" =~ ^[A-Za-z0-9][A-Za-z0-9._]*$ ]] && MANUAL_APP_PACKAGE="$value"
        ;;
    esac
  done < "$CONFIG_FILE"
}

save_config() {
  umask 077
  mkdir -p "$CONFIG_DIR"
  printf 'PLACE_ID=%s\nREFRESH_SECONDS=%s\nMANUAL_APP_PACKAGE=%s\n' "$PLACE_ID" "$REFRESH_SECONDS" "$MANUAL_APP_PACKAGE" > "$CONFIG_FILE"
}

pause() {
  printf '\n'
  read -r -p '  Tekan Enter untuk kembali...' _
}

write_banner() {
  clear
  printf '\n'
  printf "${CYAN}  M   M   OOO   CCCC H   H IIIII W   W${RESET}\n"
  printf "${CYAN}  MM MM  O   O C     H   H   I   W   W${RESET}\n"
  printf "${CYAN}  M M M  O   O C     HHHHH   I   W W W${RESET}\n"
  printf "${CYAN}  M   M  O   O C     H   H   I   WW WW${RESET}\n"
  printf "${CYAN}  M   M   OOO   CCCC H   H IIIII W   W${RESET}\n"
  printf "${GRAY}  Version 1.0.5 | Roblox Rejoin Menu for Termux${RESET}\n\n"
  printf "${GRAY}  --------------------------------------------------------${RESET}\n\n"
}

extract_place_id() {
  local value="$1"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s' "$value"
  elif [[ "$value" =~ roblox\.com/games/([0-9]+) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    return 1
  fi
}

is_configured() {
  if [[ -z "$PLACE_ID" ]]; then
    printf "${YELLOW}  Belum ada Place ID. Pilih Setup terlebih dahulu.${RESET}\n"
    pause
    return 1
  fi
}

setup_place() {
  local input_value new_place_id seconds_input
  write_banner
  printf "${CYAN}  MASUKKAN PLACE${RESET}\n"
  printf "${GRAY}  Tempel Place ID atau URL game, contoh:${RESET}\n"
  printf "${GRAY}  https://www.roblox.com/games/123456789/Nama-Game${RESET}\n\n"

  read -r -p '  Place ID / URL: ' input_value
  if ! new_place_id="$(extract_place_id "$input_value")"; then
    printf "${RED}  Place ID/URL tidak valid.${RESET}\n"
    pause
    return
  fi

  PLACE_ID="$new_place_id"
  read -r -p '  Jeda rejoin tes dalam detik [90]: ' seconds_input
  if [[ -n "$seconds_input" ]]; then
    if [[ "$seconds_input" =~ ^[0-9]+$ ]] && (( seconds_input >= 30 )); then
      REFRESH_SECONDS="$seconds_input"
    else
      printf "${YELLOW}  Jeda minimal 30 detik. Nilai lama dipertahankan.${RESET}\n"
    fi
  fi

  save_config
  printf "${GREEN}  Tersimpan: Place ID %s${RESET}\n" "$PLACE_ID"
  pause
}

open_game() {
  local deep_link
  is_configured || return
  deep_link="roblox://placeId=${PLACE_ID}"

  # Deep link resmi Roblox untuk masuk langsung ke Place ID.
  if command -v am >/dev/null 2>&1; then
    am start -a android.intent.action.VIEW -d "$deep_link" >/dev/null 2>&1 || {
      printf "${RED}  Deep link Roblox tidak dapat dibuka.${RESET}\n"
      return 1
    }
  elif command -v termux-open-url >/dev/null 2>&1; then
    termux-open-url "$deep_link" >/dev/null 2>&1 || {
      printf "${RED}  Deep link Roblox tidak dapat dibuka.${RESET}\n"
      return 1
    }
  else
    printf "${RED}  termux-open-url dan am tidak tersedia.${RESET}\n"
    return 1
  fi

  printf "${GREEN}  Mencoba masuk langsung ke game Roblox...${RESET}\n"
}

// ==UserScript==
// @name         PlatoBoost
// @namespace    https://platorelay.com
// @version      1.0.7
// @description  Automated key bypass for PlatoBoost
// @author       PlatoBoost
// @match        https://platorelay.com/*
// @match        https://auth.platorelay.com/*
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_xmlhttpRequest
// @grant        GM.getValue
// @grant        GM.setValue
// @grant        GM.xmlHttpRequest
// @inject-into  content
// @run-at       document-idle
// ==/UserScript==

// GM shim for Tampermonkey, Violentmonkey, and Safari Userscripts
(function() {

  var hasDot  = typeof GM  !== "undefined" && typeof GM.getValue  === "function";
  var hasUnd  = typeof GM_getValue === "function" && !hasDot;
  var hasXhrDot = hasDot && typeof GM.xmlHttpRequest === "function";
  var hasXhrUnd = typeof GM_xmlhttpRequest === "function";

  // pref cache
  var __pb_store = {};

  if (!hasUnd) {
    window.GM_getValue = function(key, def) {
      return (key in __pb_store) ? __pb_store[key] : (def !== undefined ? def : undefined);
    };
  } else {

    var _orig_get = GM_getValue;
    window.GM_getValue = function(key, def) { return (key in __pb_store) ? __pb_store[key] : def; };
  }

  if (!hasUnd) {
    window.GM_setValue = function(key, val) {
      __pb_store[key] = val;
      try {
        if (hasDot)  { GM.setValue(key, val); }
        else         { localStorage.setItem("__pbgm_" + key, val); }
      } catch(e) {}
    };
  } else {
    window.GM_setValue = function(key, val) {
      __pb_store[key] = val;
      try { GM_setValue(key, val); } catch(e) {}
    };
  }

  if (!hasXhrUnd && hasXhrDot) {
    window.GM_xmlhttpRequest = function(opts) { return GM.xmlHttpRequest(opts); };
  } else if (!hasXhrUnd && !hasXhrDot) {
    // plain XHR fallback, no CORS bypass
    window.GM_xmlhttpRequest = function(opts) {
      var xhr = new XMLHttpRequest();
      xhr.open(opts.method || "GET", opts.url);
      if (opts.headers) { Object.keys(opts.headers).forEach(function(h) { try { xhr.setRequestHeader(h, opts.headers[h]); } catch(e) {} }); }
      if (opts.responseType) xhr.responseType = opts.responseType;
      xhr.onload    = function() { if (opts.onload)    opts.onload(xhr); };
      xhr.onerror   = function() { if (opts.onerror)   opts.onerror(xhr); };
      xhr.ontimeout = function() { if (opts.ontimeout) opts.ontimeout(xhr); };
      xhr.send(opts.data || null);
    };
  }

  // load all prefs, async on Safari
  var PREF_KEYS = [
    "__pb_provider", "__pb_trw_key", "__pb_bt_key", "__pb_bv_key",
    "__pb_auto_captcha", "__pb_fast_tokens", "__pb_theme", "__pb_setup_done"
  ];
  var PREF_DEFAULTS = {
    "__pb_provider": "trw", "__pb_trw_key": "", "__pb_bt_key": "", "__pb_bv_key": "",
    "__pb_auto_captcha": "1", "__pb_fast_tokens": "1", "__pb_theme": "dark", "__pb_setup_done": ""
  };

  window.__pbInitPrefs = function() {
    if (hasDot) {
      // Safari
      return Promise.all(PREF_KEYS.map(function(k) {
        return GM.getValue(k, PREF_DEFAULTS[k]).then(function(v) {
          __pb_store[k] = (v === undefined || v === null) ? PREF_DEFAULTS[k] : v;
        }).catch(function() { __pb_store[k] = PREF_DEFAULTS[k]; });
      }));
    } else if (hasUnd) {
      // Tampermonkey / Violentmonkey
      PREF_KEYS.forEach(function(k) {
        var v; try { v = _orig_get(k, PREF_DEFAULTS[k]); } catch(e) { v = PREF_DEFAULTS[k]; }
        __pb_store[k] = (v === undefined || v === null) ? PREF_DEFAULTS[k] : v;
      });
      return Promise.resolve();
    } else {
      // localStorage fallback
      PREF_KEYS.forEach(function(k) {
        try { var v = localStorage.getItem("__pbgm_" + k); __pb_store[k] = v === null ? PREF_DEFAULTS[k] : v; }
        catch(e) { __pb_store[k] = PREF_DEFAULTS[k]; }... (36 KB left)
        
open_browser_join() {
  local game_url
  is_configured || return
  game_url="https://www.roblox.com/games/start?placeId=${PLACE_ID}"

  if command -v termux-open-url >/dev/null 2>&1; then
    termux-open-url "$game_url" >/dev/null 2>&1 || {
      printf "${RED}  Tautan cadangan tidak dapat dibuka.${RESET}\n"
      return 1
    }
  elif command -v am >/dev/null 2>&1; then
    am start -a android.intent.action.VIEW -d "$game_url" >/dev/null 2>&1 || {
      printf "${RED}  Tautan cadangan tidak dapat dibuka.${RESET}\n"
      return 1
    }
  else
    printf "${RED}  termux-open-url dan am tidak tersedia.${RESET}\n"
    return 1
  fi

  printf "${GREEN}  Membuka tautan cadangan Roblox...${RESET}\n"
}

roblox_is_running() {
  local process_id
  process_id="$(pidof com.roblox.client 2>/dev/null || true)"
  [[ -n "$process_id" ]]
}

run_roblox_monitor() {
  local key check_interval
  check_interval=5
  write_banner
  is_configured || return

  if ! command -v pidof >/dev/null 2>&1; then
    printf "${RED}  Perintah pidof tidak tersedia di perangkat ini.${RESET}\n"
    pause
    return
  fi

  printf "${CYAN}  MONITOR ROBLOX & AUTO-OPEN${RESET}\n"
  printf "${GRAY}  Memeriksa apakah proses aplikasi Roblox berjalan setiap %s detik.${RESET}\n" "$check_interval"
  printf "${GRAY}  Jika aplikasi ditutup, skrip mencoba membuka game kembali.${RESET}\n"
  printf "${YELLOW}  Tidak mendeteksi disconnect jika Roblox masih terbuka di halaman Home.${RESET}\n"
  printf "${GRAY}  Jangan tutup atau swipe Termux dari daftar aplikasi terbaru.${RESET}\n"
  printf "${GRAY}  Tekan S untuk menghentikan monitor.${RESET}\n\n"

  read -r -p '  Mulai monitor? ketik YA: ' confirm
  [[ "$confirm" == 'YA' ]] || return

  while true; do
    if roblox_is_running; then
      printf "\r${GREEN}  [ONLINE] Roblox sedang berjalan | tekan S untuk berhenti ${RESET}"
    else
      printf "\r${YELLOW}  [TERTUTUP] Roblox tidak berjalan. Membuka game...             ${RESET}\n"
      open_game
      # Beri Android waktu untuk membuat proses Roblox sebelum pemeriksaan berikutnya.
      sleep 10
    fi

    for ((second = 0; second < check_interval; second++)); do
      key=''
      if read -r -s -n 1 -t 1 key; then
        if [[ "$key" == 's' || "$key" == 'S' ]]; then
          printf "\n${YELLOW}  Monitor dihentikan.${RESET}\n"
          pause
          return
        fi
      fi
    done
  done
}

detect_system_package_manager() {
  if command -v pkg >/dev/null 2>&1; then
    printf '%s' 'pkg'
  elif command -v apt >/dev/null 2>&1; then
    printf '%s' 'apt'
  elif command -v pacman >/dev/null 2>&1; then
    printf '%s' 'pacman'
  else
    return 1
  fi
}

show_project_package_manager() {
  local directory="$1"
  local detected=0

  printf "${CYAN}  PROJECT PACKAGE DETECTOR${RESET}\n"
  printf "${GRAY}  Folder: %s${RESET}\n\n" "$directory"

  if [[ -f "$directory/pnpm-lock.yaml" ]]; then
    printf "${GREEN}  [DETECTED] pnpm${RESET}  pnpm-lock.yaml\n"
    detected=1
  elif [[ -f "$directory/yarn.lock" ]]; then
    printf "${GREEN}  [DETECTED] Yarn${RESET}  yarn.lock\n"
    detected=1
  elif [[ -f "$directory/bun.lock" || -f "$directory/bun.lockb" ]]; then
    printf "${GREEN}  [DETECTED] Bun${RESET}   bun.lock / bun.lockb\n"
    detected=1
  elif [[ -f "$directory/package-lock.json" || -f "$directory/npm-shrinkwrap.json" ]]; then
    printf "${GREEN}  [DETECTED] npm${RESET}   package-lock.json / npm-shrinkwrap.json\n"
    detected=1
  elif [[ -f "$directory/package.json" ]]; then
    printf "${YELLOW}  [LIKELY]   npm${RESET}   package.json (tanpa lockfile)\n"
    detected=1
  fi

  if [[ -f "$directory/poetry.lock" ]]; then
    printf "${GREEN}  [DETECTED] Poetry${RESET} poetry.lock\n"
    detected=1
  elif [[ -f "$directory/requirements.txt" ]]; then
    printf "${GREEN}  [DETECTED] pip${RESET}    requirements.txt\n"
    detected=1
  elif [[ -f "$directory/pyproject.toml" ]]; then
    printf "${YELLOW}  [LIKELY]   Python${RESET} pyproject.toml (pip/Poetry/uv)\n"
    detected=1
  fi

  if [[ -f "$directory/Cargo.toml" ]]; then
    printf "${GREEN}  [DETECTED] Cargo${RESET}  Cargo.toml\n"
    detected=1
  fi
  if [[ -f "$directory/go.mod" ]]; then
    printf "${GREEN}  [DETECTED] Go modules${RESET} go.mod\n"
    detected=1
  fi
  if [[ -f "$directory/composer.json" ]]; then
    printf "${GREEN}  [DETECTED] Composer${RESET} composer.json\n"
    detected=1
  fi
  if [[ -f "$directory/Gemfile" ]]; then
    printf "${GREEN}  [DETECTED] Bundler${RESET} Gemfile\n"
    detected=1
  fi
  if [[ -f "$directory/pom.xml" ]]; then
    printf "${GREEN}  [DETECTED] Maven${RESET}  pom.xml\n"
    detected=1
  elif [[ -f "$directory/build.gradle" || -f "$directory/build.gradle.kts" ]]; then
    printf "${GREEN}  [DETECTED] Gradle${RESET} build.gradle / build.gradle.kts\n"
    detected=1
  fi

  if (( detected == 0 )); then
    printf "${YELLOW}  Tidak ada manifest package yang dikenali di folder ini.${RESET}\n"
  fi
}

is_safe_package_name() {
  [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9+._-]*$ ]]
}

run_termux_package_action() {
  local manager="$1" action="$2" package_name="$3"
  case "${manager}:${action}" in
    pkg:install) pkg install "$package_name" ;;
    pkg:remove) pkg uninstall "$package_name" ;;
    pkg:list) pkg list-installed ;;
    pkg:update) pkg update ;;
    pkg:upgrade) pkg upgrade ;;
    apt:install) apt install "$package_name" ;;
    apt:remove) apt remove "$package_name" ;;
    apt:list) apt list --installed ;;
    apt:update) apt update ;;
    apt:upgrade) apt upgrade ;;
    pacman:install) pacman -S "$package_name" ;;
    pacman:remove) pacman -Rns "$package_name" ;;
    pacman:list) pacman -Q ;;
    pacman:update) pacman -Sy ;;
    pacman:upgrade) pacman -Syu ;;
  esac
}

set_project_directory() {
  local selected_dir resolved_dir
  write_banner
  printf "${CYAN}  SET PROJECT FOLDER${RESET}\n"
  printf "${GRAY}  Folder saat ini: %s${RESET}\n" "$PROJECT_DIR"
  read -r -p '  Folder baru (kosong = folder saat ini): ' selected_dir
  [[ -n "$selected_dir" ]] || selected_dir="$PWD"

  if ! resolved_dir="$(cd -- "$selected_dir" 2>/dev/null && pwd -P)"; then
    printf "${RED}  Folder tidak ditemukan.${RESET}\n"
    pause
    return
  fi

  PROJECT_DIR="$resolved_dir"
  printf "${GREEN}  Project folder dipilih: %s${RESET}\n" "$PROJECT_DIR"
  pause
}

run_package_manager() {
  local manager choice package_name confirm
  manager="$(detect_system_package_manager || true)"

  while true; do
    write_banner
    printf "${CYAN}  PACKAGE MANAGER${RESET}\n"
    if [[ -n "$manager" ]]; then
      printf "${GRAY}  System manager: %s (auto-detected)${RESET}\n" "$manager"
    else
      printf "${RED}  Package manager Termux tidak ditemukan.${RESET}\n"
    fi
    printf "${GRAY}  Project folder : %s${RESET}\n\n" "$PROJECT_DIR"
    printf "${GREEN} 1)${WHITE} Auto Detect Package Manager${RESET}\n"
    printf "${GREEN} 2)${WHITE} Install Termux Package${RESET}\n"
    printf "${GREEN} 3)${WHITE} Uninstall Termux Package${RESET}\n"
    printf "${RED} 4)${WHITE} Back${RESET}\n\n"

    printf "${CYAN}[?] Enter your choice [1-4]: ${RESET}"
    read -r choice
    case "$choice" in
      1)
        write_banner
        printf "${CYAN}  AUTO DETECT PACKAGE MANAGER${RESET}\n"
        if [[ -n "$manager" ]]; then
          printf "${GREEN}  [DETECTED] System package manager: %s${RESET}\n\n" "$manager"
        else
          printf "${RED}  System package manager tidak ditemukan.${RESET}\n\n"
        fi
        show_project_package_manager "$PROJECT_DIR"
        pause
        ;;
      2|3)
        if [[ -z "$manager" ]]; then
          printf "${RED}  Tidak ada package manager yang bisa digunakan.${RESET}\n"
          pause
          continue
        fi
        read -r -p '  Nama paket Termux: ' package_name
        if ! is_safe_package_name "$package_name"; then
          printf "${RED}  Nama paket tidak valid.${RESET}\n"
          pause
          continue
        fi
        if [[ "$choice" == '3' ]]; then
          read -r -p "  Hapus paket '$package_name'? ketik YA: " confirm
          [[ "$confirm" == 'YA' ]] || continue
          run_termux_package_action "$manager" remove "$package_name"
        else
          run_termux_package_action "$manager" install "$package_name"
        fi
        pause
        ;;
      4) return ;;
      *) printf "${RED}  Pilihan tidak tersedia.${RESET}\n"; sleep 1 ;;
    esac
  done
}

detect_launchable_apps() {
  local user_packages component package_name
  local -a detected_components=()

  if ! command -v pm >/dev/null 2>&1 || ! command -v cmd >/dev/null 2>&1; then
    return 1
  fi

  user_packages="$(pm list packages -3 2>/dev/null | sed 's/^package://')"
  while IFS= read -r component; do
    [[ "$component" == */* ]] || continue
    package_name="${component%%/*}"
    if grep -Fqx -- "$package_name" <<< "$user_packages"; then
      detected_components+=("$component")
      (( ${#detected_components[@]} == 10 )) && break
    fi
  done < <(cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>/dev/null)

  (( ${#detected_components[@]} > 0 )) || return 0
  (IFS=$'\n'; printf '%s\n' "${detected_components[@]}")
}

launch_android_app() {
  local component="$1"
  am start -n "$component" >/dev/null 2>&1
}

is_safe_android_package_id() {
  [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._]*$ ]]
}

is_android_package_installed() {
  command -v pm >/dev/null 2>&1 && pm path "$1" >/dev/null 2>&1
}

set_manual_android_app() {
  local package_id
  write_banner
  printf "${CYAN}  MANUAL APP DETECTION${RESET}\n"
  printf "${GRAY}  Cari dahulu package ID aplikasi dengan perintah:${RESET}\n"
  printf "${GRAY}  pm list packages | grep -iE 'roblox|mercy'${RESET}\n\n"
  read -r -p '  Masukkan package ID aplikasi: ' package_id

  if ! is_safe_android_package_id "$package_id"; then
    printf "${RED}  Format package ID tidak valid.${RESET}\n"
    pause
    return
  fi
  if ! is_android_package_installed "$package_id"; then
    printf "${RED}  Aplikasi tidak ditemukan dengan package ID tersebut.${RESET}\n"
    pause
    return
  fi

  MANUAL_APP_PACKAGE="$package_id"
  save_config
  printf "${GREEN}  [DETECTED] Aplikasi tersimpan: %s${RESET}\n" "$MANUAL_APP_PACKAGE"
  pause
}

auto_detect_manual_android_app() {
  local choice selected_package
  local -a candidates=()

  if ! command -v pm >/dev/null 2>&1; then
    printf "${RED}  Perintah pm tidak tersedia.${RESET}\n"
    pause
    return
  fi

  mapfile -t candidates < <(pm list packages -3 2>/dev/null | sed 's/^package://' | grep -iE 'roblox|mercy')
  write_banner
  printf "${CYAN}  AUTO DETECT ROBLOX / NO MERCY${RESET}\n\n"

  if (( ${#candidates[@]} == 0 )); then
    printf "${YELLOW}  Tidak ada package pihak ketiga dengan nama roblox atau mercy.${RESET}\n"
    printf "${GRAY}  Gunakan Set Manual App Package untuk memasukkan package ID sendiri.${RESET}\n"
    pause
    return
  fi

  if (( ${#candidates[@]} == 1 )); then
    selected_package="${candidates[0]}"
  else
    printf "${GRAY}  Ditemukan %d package. Pilih salah satu:${RESET}\n" "${#candidates[@]}"
    for ((index = 0; index < ${#candidates[@]}; index++)); do
      printf "${GREEN} %2d)${WHITE} %s${RESET}\n" "$((index + 1))" "${candidates[index]}"
    done
    printf '\n'
    read -r -p "  Pilih nomor [1-${#candidates[@]}]: " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#candidates[@]} )); then
      printf "${RED}  Nomor tidak valid.${RESET}\n"
      pause
      return
    fi
    selected_package="${candidates[choice - 1]}"
  fi

  if ! is_android_package_installed "$selected_package"; then
    printf "${RED}  Package terdeteksi tetapi tidak dapat diverifikasi.${RESET}\n"
    pause
    return
  fi

  MANUAL_APP_PACKAGE="$selected_package"
  save_config
  printf "${GREEN}  [MANUAL DETECTED] %s${RESET}\n" "$MANUAL_APP_PACKAGE"
  pause
}

get_roblox_candidate_packages() {
  command -v pm >/dev/null 2>&1 || return 1
  pm list packages -3 2>/dev/null | sed 's/^package://' | grep -iE 'roblox|mercy' | head -n 10
}

launch_rejoin_for_package() {
  local package_id="$1"
  local deep_link="roblox://placeId=${PLACE_ID}"

  # Minta Android mengirim deep link ke package yang dipilih.
  am start -a android.intent.action.VIEW -d "$deep_link" -p "$package_id" >/dev/null 2>&1 || \
    am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$package_id" >/dev/null 2>&1
}

run_rejoin_all_apps() {
  local confirm package_id app_index remaining key grid_index grid_next_package
  local -a candidates=()

  is_configured || return
  mapfile -t candidates < <(get_roblox_candidate_packages)
  write_banner
  printf "${CYAN}  MOCHIW REJOIN DASHBOARD${RESET}\n"
  printf "${GRAY}  Ditemukan %d aplikasi | Jeda antar aplikasi: 60 detik${RESET}\n\n" "${#candidates[@]}"

  if (( ${#candidates[@]} == 0 )); then
    printf "${RED}  Tidak ada aplikasi Roblox / No Mercy yang terdeteksi.${RESET}\n"
    pause
    return
  fi

  printf "${CYAN}  AUTO APP GRID${RESET}\n"
  printf "${CYAN}  +-------------------------------+-------------------------------+${RESET}\n"
  printf "${CYAN}  | APP  PACKAGE / STATUS          | APP  PACKAGE / STATUS          |${RESET}\n"
  printf "${CYAN}  +-------------------------------+-------------------------------+${RESET}\n"
  for ((grid_index = 0; grid_index < ${#candidates[@]}; grid_index += 2)); do
    package_id="${candidates[grid_index]}"
    if (( grid_index + 1 < ${#candidates[@]} )); then
      grid_next_package="${candidates[grid_index + 1]}"
      printf "${GRAY}  | %02d   %-18.18s PENDING | %02d   %-18.18s PENDING |${RESET}\n" \
        "$((grid_index + 1))" "$package_id" "$((grid_index + 2))" "$grid_next_package"
    else
      printf "${GRAY}  | %02d   %-18.18s PENDING |                               |${RESET}\n" \
        "$((grid_index + 1))" "$package_id"
    fi
  done
  printf "${CYAN}  +-------------------------------+-------------------------------+${RESET}\n"
  printf "${GRAY}  Tekan S saat jeda untuk menghentikan proses.${RESET}\n\n"

  read -r -p '  Mulai rejoin semua aplikasi? ketik YA: ' confirm
  [[ "$confirm" == 'YA' ]] || return

  for ((app_index = 0; app_index < ${#candidates[@]}; app_index++)); do
    package_id="${candidates[app_index]}"
    if launch_rejoin_for_package "$package_id"; then
      printf "${GREEN}  [%d/%d] %-22s -> Rejoin requested${RESET}\n" "$((app_index + 1))" "${#candidates[@]}" "$package_id"
    else
      printf "${RED}  [%d/%d] %-22s -> Launch failed${RESET}\n" "$((app_index + 1))" "${#candidates[@]}" "$package_id"
    fi

    (( app_index == ${#candidates[@]} - 1 )) && break

    remaining=60
    while (( remaining > 0 )); do
      printf "\r${GRAY}  Aplikasi berikutnya dalam %2d detik | tekan S untuk berhenti ${RESET}" "$remaining"
      key=''
      if read -r -s -n 1 -t 1 key; then
        if [[ "$key" == 's' || "$key" == 'S' ]]; then
          printf "\n${YELLOW}  Rejoin semua aplikasi dihentikan.${RESET}\n"
          pause
          return
        fi
      fi
      ((remaining--))
    done
    printf '\n'
  done

  printf "${GREEN}  Semua aplikasi terdeteksi telah diproses.${RESET}\n"
  pause
}

launch_manual_android_app() {
  if [[ -z "$MANUAL_APP_PACKAGE" ]]; then
    printf "${YELLOW}  Belum ada aplikasi manual yang dikonfigurasi.${RESET}\n"
    return 1
  fi
  if ! is_android_package_installed "$MANUAL_APP_PACKAGE"; then
    printf "${RED}  Package manual tidak lagi terpasang: %s${RESET}\n" "$MANUAL_APP_PACKAGE"
    return 1
  fi
  am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$MANUAL_APP_PACKAGE" >/dev/null 2>&1
}

run_app_detector() {
  local choice app_number confirm component
  local -a apps=()

  while true; do
    mapfile -t apps < <(detect_launchable_apps)
    write_banner
    printf "${CYAN}  APP DETECTOR & LAUNCHER${RESET}\n"
    printf "${GRAY}  Menampilkan maksimal 10 aplikasi pengguna yang memiliki launcher.${RESET}\n"
    printf "${YELLOW}  Android hanya menampilkan satu aplikasi di depan; aplikasi lain bisa${RESET}\n"
    printf "${YELLOW}  dijeda atau dihentikan sistem ketika berada di latar belakang.${RESET}\n\n"

    if (( ${#apps[@]} == 0 )); then
      printf "${RED}  Tidak ada aplikasi launchable yang terdeteksi, atau akses ditolak.${RESET}\n"
    else
      for ((index = 0; index < ${#apps[@]}; index++)); do
        printf "${GREEN} %2d)${WHITE} %s${RESET}\n" "$((index + 1))" "${apps[index]}"
      done
    fi

    if [[ -n "$MANUAL_APP_PACKAGE" ]]; then
      if is_android_package_installed "$MANUAL_APP_PACKAGE"; then
        printf "${GREEN}  [MANUAL DETECTED] %s${RESET}\n" "$MANUAL_APP_PACKAGE"
      else
        printf "${RED}  [MANUAL MISSING] %s${RESET}\n" "$MANUAL_APP_PACKAGE"
      fi
    fi

    printf '\n'
    printf "${GREEN} 1)${WHITE} Launch satu aplikasi berdasarkan nomor${RESET}\n"
    printf "${GREEN} 2)${WHITE} Launch semua aplikasi yang terdeteksi (maks. 10)${RESET}\n"
    printf "${GREEN} 3)${WHITE} Scan ulang${RESET}\n"
    printf "${GREEN} 4)${WHITE} Auto Detect Roblox / No Mercy${RESET}\n"
    printf "${GREEN} 5)${WHITE} Set Manual App Package${RESET}\n"
    printf "${GREEN} 6)${WHITE} Launch Manual App${RESET}\n"
    printf "${GREEN} 7)${WHITE} Rejoin All Detected Apps (60 sec)${RESET}\n"
    printf "${RED} 8)${WHITE} Back${RESET}\n\n"
    printf "${CYAN}[?] Enter your choice [1-8]: ${RESET}"
    read -r choice

    case "$choice" in
      1)
        if (( ${#apps[@]} == 0 )); then
          pause
          continue
        fi
        read -r -p "  Nomor aplikasi [1-${#apps[@]}]: " app_number
        if [[ ! "$app_number" =~ ^[0-9]+$ ]] || (( app_number < 1 || app_number > ${#apps[@]} )); then
          printf "${RED}  Nomor tidak valid.${RESET}\n"
          pause
          continue
        fi
        component="${apps[app_number - 1]}"
        if launch_android_app "$component"; then
          printf "${GREEN}  Membuka %s${RESET}\n" "$component"
        else
          printf "${RED}  Aplikasi tidak dapat dibuka oleh Android.${RESET}\n"
        fi
        pause
        ;;
      2)
        if (( ${#apps[@]} == 0 )); then
          pause
          continue
        fi
        read -r -p '  Membuka seluruh aplikasi terdeteksi? ketik YA: ' confirm
        [[ "$confirm" == 'YA' ]] || continue
        for component in "${apps[@]}"; do
          launch_android_app "$component" || true
          sleep 1
        done
        printf "${GREEN}  Permintaan buka dikirim untuk %d aplikasi.${RESET}\n" "${#apps[@]}"
        pause
        ;;
      3) continue ;;
      4) auto_detect_manual_android_app ;;
      5) set_manual_android_app ;;
      6)
        if launch_manual_android_app; then
          printf "${GREEN}  Membuka %s${RESET}\n" "$MANUAL_APP_PACKAGE"
        fi
        pause
        ;;
      7) run_rejoin_all_apps ;;
      8) return ;;
      *) printf "${RED}  Pilihan tidak tersedia.${RESET}\n"; sleep 1 ;;
    esac
  done
}

run_auto_rejoin_test() {
  local cycle_input cycles confirm cycle remaining key
  write_banner
  is_configured || return

  printf "${CYAN}  AUTO-REJOIN TEST${RESET}\n"
  printf "${GRAY}  Mode ini membuka ulang halaman place pada interval pilihan.${RESET}\n"
  printf "${YELLOW}  Gunakan hanya untuk menguji pengalaman milik Anda sendiri.${RESET}\n"
  printf "${GRAY}  Tekan S saat hitung mundur untuk berhenti.${RESET}\n\n"

  read -r -p '  Jumlah rejoin (1-10) [3]: ' cycle_input
  cycles=3
  if [[ -n "$cycle_input" ]]; then
    if [[ "$cycle_input" =~ ^[0-9]+$ ]] && (( cycle_input >= 1 && cycle_input <= 10 )); then
      cycles="$cycle_input"
    else
      printf "${RED}  Jumlah harus 1 sampai 10.${RESET}\n"
      pause
      return
    fi
  fi

  read -r -p '  Mulai? ketik YA: ' confirm
  [[ "$confirm" == 'YA' ]] || return

  for ((cycle = 1; cycle <= cycles; cycle++)); do
    printf '\n'
    printf "${CYAN}  Rejoin %d dari %d${RESET}\n" "$cycle" "$cycles"
    open_game

    (( cycle == cycles )) && break

    remaining="$REFRESH_SECONDS"
    while (( remaining > 0 )); do
      printf "\r${GRAY}  Rejoin berikutnya dalam %3d dtk | tekan S untuk berhenti ${RESET}" "$remaining"
      key=''
      if read -r -s -n 1 -t 1 key; then
        if [[ "$key" == 's' || "$key" == 'S' ]]; then
          printf "\n${YELLOW}  Sesi dihentikan.${RESET}\n"
          pause
          return
        fi
      fi
      ((remaining--))
    done
    printf '\n'
  done

  printf "${GREEN}  Sesi auto-rejoin selesai.${RESET}\n"
  pause
}

show_help() {
  write_banner
  printf "${CYAN}  BANTUAN${RESET}\n"
  printf "${GRAY}  - Skrip ini membuka URL game Roblox yang dipilih.${RESET}\n"
  printf "${GRAY}  - Deteksi disconnect Roblox tidak tersedia dari Termux, karena Termux${RESET}\n"
  printf "${GRAY}    tidak dapat membaca status koneksi di dalam aplikasi Roblox.${RESET}\n"
  printf "${GRAY}  - Menu Monitor mendeteksi aplikasi Roblox yang ditutup (proses mati),${RESET}\n"
  printf "${GRAY}    lalu mencoba membuka game lagi. Termux harus tetap berjalan.${RESET}\n"
  printf "${GRAY}  - Auto-rejoin test hanya membuka ulang halaman game sesuai interval.${RESET}\n"
  printf "${GRAY}    Hentikan dengan tombol S.${RESET}\n"
  printf "${GRAY}  - Koneksi internet Android dapat dicek dengan: ping -c 1 1.1.1.1${RESET}\n"
  printf "${GRAY}  - Pastikan aplikasi Roblox terpasang dan Anda sudah masuk akun.${RESET}\n"
  printf "${GRAY}  - Untuk rejoin produksi dari dalam game, gunakan TeleportService${RESET}\n"
  printf "${GRAY}    pada Script server di Roblox Studio.${RESET}\n"
  pause
}

load_config

while true; do
  write_banner
  if [[ -n "$PLACE_ID" ]]; then
    place_label="$PLACE_ID"
  else
    place_label='belum diatur'
  fi

  printf "${CYAN}What would you like to do?${RESET}\n"
  printf "${GREEN} 1)${WHITE} Setup Configuration (First Run)${RESET}\n"
  printf "${GREEN} 2)${WHITE} Edit Configuration${RESET}\n"
  printf "${GREEN} 3)${WHITE} Join Game Now${RESET}\n"
  printf "${GREEN} 4)${WHITE} Monitor Roblox & Auto-Open${RESET}\n"
  printf "${GREEN} 5)${WHITE} Run Auto-Rejoin Test (Timer)${RESET}\n"
  printf "${GREEN} 6)${WHITE} Open Join Link (Fallback)${RESET}\n"
  printf "${GREEN} 7)${WHITE} Help & Information${RESET}\n"
  printf "${GREEN} 8)${WHITE} Package Manager & Project Detector${RESET}\n"
  printf "${GREEN} 9)${WHITE} App Detector & Launcher (max. 10)${RESET}\n"
  printf "${RED}10)${WHITE} Exit${RESET}\n\n"
  printf "${GRAY} Place ID: %s | Interval: %s sec${RESET}\n\n" "$place_label" "$REFRESH_SECONDS"

  printf "${CYAN}[?] Enter your choice [1-10]: ${RESET}"
  read -r choice
  case "$choice" in
    1|2) setup_place ;;
    3) write_banner; open_game; pause ;;
    4) run_roblox_monitor ;;
    5) run_auto_rejoin_test ;;
    6) write_banner; open_browser_join; pause ;;
    7) show_help ;;
    8) run_package_manager ;;
    9) run_app_detector ;;
    10) exit 0 ;;
    *) printf "${RED}  Pilihan tidak tersedia.${RESET}\n"; sleep 1 ;;
  esac
done
