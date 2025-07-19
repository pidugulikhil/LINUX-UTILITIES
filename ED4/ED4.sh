#!/bin/bash

META_DIR="./.enc_meta"
mkdir -p "$META_DIR"
LOG_FILE="encdec.log"
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
echo -e "${RED}"

# Spinner for long ops
spinner() {
  local pid=$1
  local chars='|/-\'
  while kill -0 $pid 2>/dev/null; do
    for c in $chars; do
      echo -ne "${CYAN}\r$c Processing...${NC}"
      sleep 0.1
    done
  done
  echo -e "\r${GREEN}✔ Done!            ${NC}"
}

perm_value() {
  stat --format '%a' "$1" \
    | awk '{ split($0,a,""); sum=0; for(i in a) sum+=a[i]; print sum }'
}


print_header() {
  clear
  figlet -c "ED4 Utility" | lolcat       # pip install lolcat for rainbow colors (optional)
  echo -e "${CYAN} Four‑Layer Encryption / Decryption CLI Utility ${NC}"
  echo
}


# Utility functions
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}
perm_value() {
    stat --format '%a' "$1" | awk '{split($0,a,""); sum=0; for(i in a) sum+=a[i]; print sum}'
}

rotate_string() {
    str="$1"; rot=$2; len=${#str}
    if (( len == 0 )); then
        echo ""
        return
    fi
    (( rot = rot % len ))
    echo "${str: -$rot}${str:0:$((len - rot))}"
}

# Level 1 - ASCII Shift
level1_encrypt() {
    shift=$1
    log "Level 1 Encryption: ASCII Shift +$shift"
    perl -CS -pe "s/(.)/chr((ord(\$1)+$shift)%256)/ge"
}
level1_decrypt() {
    shift=$1
    log "Level 1 Decryption: ASCII Shift -$shift"
    perl -CS -pe "s/(.)/chr((ord(\$1)-$shift+256)%256)/ge"
}

# Level 2 - Reverse + Rotate
level2_encrypt() {
    log "Level 2 Encryption: Reverse + Rotate"
    rev | awk -v r=5 '{line=$0; len=length(line); r%=len; print substr(line,len-r+1) substr(line,1,len-r)}'
}
level2_decrypt() {
    log "Level 2 Decryption: Reverse + Rotate"
    awk -v r=5 '{line=$0; len=length(line); r%=len; print substr(line,r+1) substr(line,1,r)}' | rev
}

# Level 3 - ROT-like Cipher
rot_custom_encrypt() {
    log "Level 3 Encryption: Custom Cipher"
    tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5678901234'
}
rot_custom_decrypt() {
    log "Level 3 Decryption: Custom Cipher"
    tr 'N-ZA-Mn-za-m5678901234' 'A-Za-z0-9'
}

# Level 4 - Base64 + Shuffle
level4_encrypt() {
    log "Level 4 Encryption: Base64 + Shuffle"
    base64 | tr -d '\n' | fold -w6 | tac | paste -sd ''
}
level4_decrypt() {
    log "Level 4 Decryption: Base64 + Shuffle"
    fold -w6 | tac | paste -sd '' | base64 -d 2>/dev/null
}

# Encrypt file
encrypt_file() {
    clear
    echo -e "${CYAN}========== ENCRYPTION STARTED ==========${NC}"
    file="$1"
    [[ ! -f "$file" ]] && echo -e "${RED}File not found!${NC}" && return

    perm_sum=$(perm_value "$file")

    echo -e "${YELLOW}Using the following encryption layers:${NC}"
    echo -e "${GREEN}  ➤ Layer 1: ASCII Shift based on file permissions (${perm_sum})"
    echo -e "  ➤ Layer 2: Reverse string + character rotation"
    echo -e "  ➤ Layer 3: Custom ROT Cipher"
    echo -e "  ➤ Layer 4: Base64 + block shuffle${NC}"
    echo

    < "$file" \
        level1_encrypt "$perm_sum" |  \
        level2_encrypt | \
        rot_custom_encrypt | \
        level4_encrypt \
        > "$file.enc"

    echo "$perm_sum" > "$META_DIR/$(basename "$file").meta"
    log "Encrypted $file to $file.enc with permission sum $perm_sum"

    echo -e "${GREEN}Encryption complete: $file.enc${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# Decrypt file
decrypt_file() {
    clear
    echo -e "${CYAN}========== DECRYPTION STARTED ==========${NC}"
    file="$1"
    base=$(basename "$file" .enc)
    meta="$META_DIR/$base.meta"

    [[ ! -f "$file" || ! -f "$meta" ]] && echo -e "${RED}File or metadata missing!${NC}" && return

    perm_sum=$(<"$meta")

    echo -e "${YELLOW}Applying decryption layers in reverse:${NC}"
    echo -e "${GREEN}  ➤ Layer 4: Block shuffle reversal + Base64 decode"
    echo -e "  ➤ Layer 3: Custom ROT Cipher reverse"
    echo -e "  ➤ Layer 2: Reverse rotation + string reverse"
    echo -e "  ➤ Layer 1: ASCII Shift reverse using permission sum (${perm_sum})${NC}"
    echo

    < "$file" \
        level4_decrypt | \
        rot_custom_decrypt | \
        level2_decrypt | \
        level1_decrypt "$perm_sum" \
        > "$base.dec"

    log "Decrypted $file to $base.dec using permission sum $perm_sum"

    echo -e "${GREEN}Decryption complete: $base.dec${NC}"
    echo -e "${CYAN}==========================================${NC}"
}

# View file contents safely
view_file() {
    clear
    echo -e "${CYAN}========== VIEW FILE CONTENT ==========${NC}"
    read -p "Enter the path of the file to view: " file
    if [[ -f "$file" ]]; then
        echo -e "${YELLOW}--- Begin of $file ---${NC}"
        cat "$file"
        echo -e "${YELLOW}--- End of $file ---${NC}"
    else
        echo -e "${RED}File not found.${NC}"
    fi
    echo -e "${CYAN}=======================================${NC}"
    read -p "Press ENTER to return to menu..."
}

# Show logs
view_logs() {
    clear
    echo -e "${CYAN}========== ACTIVITY LOG ==========${NC}"
    cat "$LOG_FILE" 2>/dev/null || echo "No logs yet."
    echo -e "${CYAN}==================================${NC}"
    read -p "Press ENTER to return to menu..."
}

# Main menu
main_menu() {
    clear
    # Big banner
    figlet -f slant ED4
    echo -e "${NC}"
    echo
    # Framed title
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}   Files Encryption & Decryption Utility CLI      ${CYAN}║${NC}"
    echo -e "${CYAN}║${MAGENTA}            ✨ MADE BY LIKHIL & CO ✨             ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════╣${NC}"
    echo 
    echo
    # Menu options
    echo -e "${GREEN}  [1]${NC} 🔒 Encrypt File"
    echo -e "${GREEN}  [2]${NC} 🔒 Decrypt File"
    echo -e "${GREEN}  [3]${NC} 📜 View Logs"
    echo -e "${GREEN}  [4]${NC} 📂 View a File"
    echo -e "${RED}  [5]${NC} ❌ Exit"
    echo 
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
	echo
    read -p "👉 Select an option [1-5]: " choice

    case $choice in
        1)
            read -p "Enter file path to encrypt: " path
            encrypt_file "$path"
            read -p "Press ENTER to continue..."; main_menu;;
        2)
            read -p "Enter .enc file to decrypt: " path
            decrypt_file "$path"
            read -p "Press ENTER to continue..."; main_menu;;
        3)
            view_logs; main_menu;;
        4)
            view_file; main_menu;;
        5)
            echo "Goodbye!"; exit 0;;
        *)
            echo -e "${RED}Invalid choice.${NC}"; sleep 1; main_menu;;
    esac
}

main_menu
