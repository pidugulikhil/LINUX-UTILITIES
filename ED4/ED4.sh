#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
CYAN='\033[1;36m'
GREEN='\033[1;92m'
UWHITE='\033[4;37m'
BGCYAN='\033[46m' 
UYELLOW='\033[4;33m' 

LOG_FILE="encdec.log"
META_DIR="./.enc_meta"
mkdir -p "$META_DIR"

#################### LOGS
log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

###################### BANNER
show_banner() {
    clear
    echo -e "${CYAN}                                                     ${RED}_____${NC}        "
	echo -e "${CYAN}EEEEEEEEEEEEEEEEEEEE DDDDDDDDDDDDD        ${RED}          4:::::4"
	echo -e "${CYAN}E::::::::::::::::::E D::::::::::::DD      ${RED}         4::::::4   "
	echo -e "${CYAN}EE:::::EEEEEEEE::::E DDD:::DDDDD::::DD    ${RED}        4::44:::4   "
	echo -e "${CYAN}  E::::E       EEEE    D::::D    D::::D   ${RED}      4:::4 4:::4   "
	echo -e "${CYAN}  E::::E               D::::D     D::::D  ${RED}     4:::4  4:::4   "
	echo -e "${CYAN}  E::::EEEEEEEEEE      D::::D     D::::D  ${RED}    4:::4   4:::4   "
	echo -e "${CYAN}  E:::::::::::::E      D::::D     D::::D  ${RED}    4::::::::::::44 "
	echo -e "${CYAN}  E::::EEEEEEEEEE      D::::D     D::::D  ${RED}    444444444::::44 "
	echo -e "${CYAN}  E::::E               D::::D     D::::D  ${RED}            4:::4   "
	echo -e "${CYAN}  E::::E       EEEE    D::::D    D::::D   ${RED}            4:::4   "
	echo -e "${CYAN}EE:::::EEEEEEEE::::E DDD:::DDDDD::::DD    ${RED}            4:::4   "
	echo -e "${CYAN}E::::::::::::::::::E D::::::::::::DD      ${RED}           44:::4 "
	echo -e "${CYAN}EEEEEEEEEEEEEEEEEEEE DDDDDDDDDDDDD        ${RED}          4444444 "
	echo -e "${NC}"
	
    #figlet -f smslant ED4
    echo -e "${CYAN}====== ${BGCYAN}ED4${NC} ${CYAN}Universal File Encryption Utility${NC}${CYAN} ======${NC}"
    echo -e "${YELLOW}            🔐 Created by ${UYELLOW}LIKHIL & CO${NC}"
}

####################################################################
#FILE PERMISSIONS LOCATOR/ANALYSER
# Calculates shift from file permission, e.g., 755 => 7+5+5 = 17
#get_perm_shift() {
#    local perm
#    perm=$(stat -c '%a' "$1")
#    echo $(( ${perm:0:1} + ${perm:1:1} + ${perm:2:1} ))
#}
get_perm_shift() {
    local file="$1"
    local perm
    perm=$(stat -c "%a" "$file")
    local sum=0
    for ((i=0; i<${#perm}; i++)); do
        sum=$((sum + ${perm:$i:1}))
    done
    echo "$sum"
}


####################################################################
# Layer 1 — Binary-safe ASCII shift using hex + xxd

layer1_encrypt() {
    local shift=$1
    xxd -p -c 1 | \
    awk -v s="$shift" '{ 
        v = strtonum("0x" $0); 
        v = (v + s) % 256; 
        printf("%02x\n", v) 
    }' | xxd -r -p
}

layer1_decrypt() {
    local shift=$1
    xxd -p -c 1 | \
    awk -v s="$shift" '{ 
        v = strtonum("0x" $0); 
        v = (v - s + 256) % 256; 
        printf("%02x\n", v) 
    }' | xxd -r -p
}

####################################################################
# 2nd LAYER ALGORITHM REVERSE+ROTATE
layer2_encrypt() {
    xxd -p | tr -d '\n' | rev | xxd -r -p
}

layer2_decrypt() {
    xxd -p | tr -d '\n' | rev | xxd -r -p
}


####################################################################
# NXR4 Algorithm: Byte-wise nibble swap (low 4 bits <-> high 4 bits)
# This awk-based pipeline processes hex bytes as a stream to reduce CPU/memory usage

encrypt3_layer() {
    infile="$1"
    outfile="$2"

    xxd -p "$infile" | tr -d '\n' | fold -w2 | awk '
    /^[0-9a-fA-F]{2}$/ {
        byte = strtonum("0x" $0)
        high = and(rshift(byte, 4), 0x0F)
        low = and(byte, 0x0F)
        swapped = or(lshift(low, 4), high)
        printf "%02x", swapped
    }' | xxd -r -p > "$outfile"
}

decrypt3_layer() {
    encrypt3_layer "$@"
}

####################################################################
# ==========================
# 4th LAYER BASE64 + SHIFT4
# ==========================
encrypt4_layer() {
    infile="$1"
    outfile="$2"

    base64 "$infile" | tr -d '\n' > /tmp/l4_base64.tmp

    content=$(< /tmp/l4_base64.tmp)
    total_len=${#content}
    block_len=$(( (total_len + 3) / 4 ))

    b1="${content:0:block_len}"
    b2="${content:block_len:block_len}"
    b3="${content:block_len*2:block_len}"
    b4="${content:block_len*3}"

    rotated="${b4}${b3}${b2}${b1}"
    echo -n "$rotated" > "$outfile"

    rm -f /tmp/l4_base64.tmp
}

decrypt4_layer() {
    infile="$1"
    outfile="$2"

    content=$(< "$infile")
    total_len=${#content}
    block_len=$(( (total_len + 3) / 4 ))

    b4="${content:0:block_len}"
    b3="${content:block_len:block_len}"
    b2="${content:block_len*2:block_len}"
    b1="${content:block_len*3}"

    original="${b1}${b2}${b3}${b4}"

    echo -n "$original" | base64 -d > "$outfile"
}


####################################################################
#ENCRYPT/DECRYPT FILES
encrypt_file() {
    clear
    trap 'rm -f "$file.enc.tmp"*; echo -e "\n${RED}Operation interrupted.${NC}"; exit 1' INT

    echo -e "${CYAN}========== ENCRYPTION STARTED ==========${GREEN}"
    read -p "Enter file path to encrypt: " file
    [[ ! -f "$file" ]] && echo -e "${RED}File not found!${NC}" && return

    # 1) Compute and sanitize shift
    shift=$(get_perm_shift "$file" | tr -d '[:space:]')
    if ! [[ "$shift" =~ ^[0-9]+$ ]] || (( shift < 0 || shift > 255 )); then
        echo -e "${RED}Invalid shift value: '$shift'${NC}"
        return
    fi
	
    # 2) Run layers 1 → 2 → 3 → 4 into temp files
    < "$file" layer1_encrypt "$shift"    > "$file.enc.tmp1"
	log "FP-ASCII SHIFT ✅"
	echo 
	echo -e "${CYAN}FP-ASCII SHIFT  ✅${NC}"
	sleep 0.1
    layer2_encrypt   < "$file.enc.tmp1"  > "$file.enc.tmp2"
	log "REVERSE+ROTATE ✅"
	echo -e "${CYAN}REVERSE+ROTATE  ✅${NC}"
	sleep 0.1
    encrypt3_layer   "$file.enc.tmp2"    "$file.enc.tmp3"
	log "NXR4 ✅"
	echo -e "${CYAN}NXR4            ✅${NC}"
	sleep 0.1
    encrypt4_layer   "$file.enc.tmp3"    "$file.enc.tmp4"
	log "BASE64+SHIFTING ✅"
	echo -e "${CYAN}BASE64+SHIFTING ✅${NC}"
	echo
	sleep 0.1
	
    # 3) Build final .enc = [1‑byte header] + [payload]
    hexshift=$(printf '%02x' "$shift")                          # e.g. "11"
    echo -ne "\x${hexshift}" > "$file.enc"                      # raw binary header
    cat "$file.enc.tmp4"      >> "$file.enc"                    # append payload

    # 4) Cleanup temps
    rm -f "$file.enc.tmp1" "$file.enc.tmp2" "$file.enc.tmp3" "$file.enc.tmp4"

    echo -e "${GREEN}Encrypted: $file.enc${NC}"
    log "===========================Encrypted $file (shift=$shift)==========================="
    echo -e "${CYAN}========================================${NC}"
}


decrypt_file() {
    clear
    trap 'rm -f "$file.enc.tmp"*; echo -e "\n${RED}Operation interrupted.${NC}"; exit 1' INT

    echo -e "${CYAN}========== DECRYPTION STARTED ==========${GREEN}"
    read -p "Enter .enc file to decrypt: " file
    [[ ! -f "$file" ]] && echo -e "${RED}File not found!${NC}" && return
    base=${file%.enc}

    # 1) Read the 1‑byte header → shift
    shift=$(dd if="$file" bs=1 count=1 2>/dev/null \
            | od -An -t u1 \
            | tr -d '[:space:]')

    # 2) Peel off the rest of the file into tmp
    dd if="$file" bs=1 skip=1 of="$file.enc.tmp1" 2>/dev/null

    # 3) Run Layers 4 → 3 → 2 + 1
    decrypt4_layer "$file.enc.tmp1" "$file.enc.tmp2"  || return
	log "BASE64+SHIFTING ✅"
	echo
	echo -e "${CYAN}BASE64+SHIFTING ✅${NC}"
	sleep 0.1
    decrypt3_layer "$file.enc.tmp2" "$file.enc.tmp3"  || return
    log "NXR4 ✅"
    echo -e "${CYAN}NXR4            ✅${NC}"
	sleep 0.1
    < "$file.enc.tmp3" layer2_decrypt \
        | layer1_decrypt "$shift" > "$base.dec"  || return
    log "REVERSE+ROTATE ✅"
    echo -e "${CYAN}REVERSE+ROTATE  ✅${NC}"
	sleep 0.1
    log "PF BASED SHIFT ✅"
    echo -e "${CYAN}PF BASED SHIFT  ✅${NC}"
	echo
	sleep 0.1 
    # 4) Clean up temps
    rm -f "$file.enc.tmp1" "$file.enc.tmp2" "$file.enc.tmp3"

    echo -e "${GREEN}Decrypted: $base.dec${NC}"
    log "===========================Decrypted $file (shift=$shift)==========================="
    echo -e "${CYAN}========================================${NC}"
}




####################################################################
#Main Menu
main_menu() {
    show_banner
    echo 
    echo -e "${GREEN}1. 🔐 ENCRYPT FILE${NC}"
    echo -e "${GREEN}2. 🔑 DECRYPT FILE${NC}"
    echo -e "${GREEN}3. 📄 VIEW FILE${NC}"
    echo -e "${GREEN}4. 🔍 VIEW LOGS${NC}"
    echo -e "${RED}5. ❌ EXIT${NC}"
    echo
    echo -e "${YELLOW}Choose Option [1-4]"
    read -p " 👉 " opt

    case $opt in
        1) encrypt_file;;
        2) decrypt_file;;
		3) 
			read -p "Enter file path to view : " view_path
			ext="${view_path##*.}"

			if [[ ! -f "$view_path" ]]; then
			    echo -e "${RED}❌ File not found: $view_path${NC}"
			else
			    case "$ext" in
			        txt|enc|dec|log|md|json|sh)
			            echo -e "${CYAN}📄 Text-based file detected (.$ext). Showing content:${NC}"
			            echo -e "${GREEN}-------------------------------------${NC}"
			            cat "$view_path"
			            echo
			            echo -e "${GREEN}-------------------------------------${NC}"
			            ;;
			        pdf|html|htm|xml)
			            echo -e "${YELLOW}🌐 Opening .$ext file in Firefox...${NC}"
			            if command -v firefox >/dev/null; then
			                firefox "file://$(realpath "$view_path")" &>/dev/null &
			            else
			                echo -e "${RED}❌ Firefox not found!${NC}"
			            fi
			            ;;
			        *)
			            echo -e "${YELLOW}🔍 Unknown extension (.$ext). Attempting to open with system viewer...${NC}"
			            if command -v xdg-open >/dev/null; then
			                xdg-open "$view_path" &>/dev/null &
			            elif command -v firefox >/dev/null; then
			                firefox "file://$(realpath "$view_path")" &>/dev/null &
			            elif command -v chromium >/dev/null; then
			                chromium "$view_path" &>/dev/null &
			            else
			                echo -e "${RED}❌ No viewer available (xdg-open/firefox/chromium not found).${NC}"
			            fi
			            ;;
			    esac
			fi
			;;
		4)
		    if [[ ! -f "$LOG_FILE" ]]; then
		        mkdir -p "$META_DIR"
		        touch "$LOG_FILE"
		        echo -e "${YELLOW}Log file not found. Creating new log...${NC}"
		    fi
		    echo -e "${CYAN}========== LOGS ==========${YELLOW}"
		    cat "$LOG_FILE"
		    echo -e "${CYAN}==========================${NC}"
		    ;;
        5) read -p "Confirm [y/n] : " confirm
       		if [[ $confirm == "y" || $confirm == "Y" || $confirm == "s" || $confirm == 1 || $confirm == "" ]]; then
		        echo -e "${RED}Goodbye${GREEN}!";
				echo " "
       			exit 0;
       		else
       			main_menu
       		fi
       		;;
       *) echo -e "${RED}Invalid option!${NC}";;
    esac
	echo -e "${YELLOW}"
    read -p "Press Enter to return..." && main_menu
}

main_menu
