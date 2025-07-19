#!/bin/bash

# =========================
# Project Permission Manager BY TRIO TEAM 
# =========================

echo "==============================================="
echo "        Welcome to the Project Permission Manager TRIO TEAM "
echo "==============================================="

read -p "Enter your Linux username: " username

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "❌ User does not exist on this system. Exiting."
    exit 1
fi

# Determine role
is_admin=$(groups "$username" | grep -E '\b(sudo|admin)\b')
uid=$(id -u "$username")

if [[ "$uid" -lt 1000 ]]; then
    role="others"
elif [[ -n "$is_admin" ]]; then
    role="admin"
else
    role="normal"
fi

echo "✅ Logged in as: $username"
echo "🔐 Role detected: $role"

# Start in user's home directory
current_dir=$(eval echo "~$username")

log_file="$HOME/permission_manager.log"

# Main menu loop
while true; do
    echo ""
    echo "------------------------------------------------"
    echo "📁 Current Directory: $current_dir"
    echo "------------------------------------------------"
    echo "Select an option:"
    echo "1) 📄 List files with permissions"
    echo "2) ✏️  Change file/folder permissions"
    echo "3) 📂 Change directory"
    echo "4) 📜 View permission change logs"
    echo "5) 🚪 Exit"
    echo "------------------------------------------------"
    read -p "Enter choice [1-5]: " choice

    case $choice in
        1)
            echo ""
            echo "🔍 Listing files in: $current_dir"
            ls -l "$current_dir"
            ;;
        2)
            read -p "Enter file/folder name or full path: " file

            # Handle absolute vs relative path
            if [[ "$file" = /* ]]; then
                target="$file"
            else
                target="$current_dir/$file"
            fi

            if [ ! -e "$target" ]; then
                echo "❌ Error: File or directory does not exist."
                continue
            fi

            owner=$(stat -c "%U" "$target")
            perms_before=$(stat -c "%A" "$target")
            group=$(stat -c "%G" "$target")

            echo "📋 File Info:"
            echo "    ➤ Path: $target"
            echo "    ➤ Owner: $owner"
            echo "    ➤ Group: $group"
            echo "    ➤ Current Permissions: $perms_before"

            # Permission logic
            if [ "$role" = "admin" ]; then
                echo "🔓 Admin access: You can change any permissions."
                chmod_cmd="sudo chmod"
            elif [ "$role" = "normal" ]; then
                if [ "$owner" != "$username" ]; then
                    echo "🚫 Access Denied: You can only modify your own files."
                    continue
                fi
                echo "✏️ Normal user: You can change your own files only."
                chmod_cmd="chmod"
            else
                echo "🚫 Access Denied: 'Others' role cannot modify files."
                continue
            fi

            echo ""
            echo "You can enter permissions in two formats:"
            echo "  ➤ Numeric (e.g., 755)"
            echo "  ➤ Natural (e.g., add read user / remove write group)"
            read -p "Enter new permission code or instruction: " perms

            status=1
            error_msg=""

            # Check if numeric
            if [[ "$perms" =~ ^[0-7]{3,4}$ ]]; then
                $chmod_cmd "$perms" "$target"
                status=$?
            else
                # Try parsing natural language format
                action=$(echo "$perms" | awk '{print $1}')
                perm_word=$(echo "$perms" | awk '{print $2}')
                entity=$(echo "$perms" | awk '{print $3}')

                # Map permission keywords
                case "$perm_word" in
                    read) perm="r" ;;
                    write) perm="w" ;;
                    execute) perm="x" ;;
                    *)
                        echo "❌ Invalid permission type: $perm_word"
                        continue
                        ;;
                esac

                # Map user/entity targets
                case "$entity" in
                    user|owner) who="u" ;;
                    group) who="g" ;;
                    others|other) who="o" ;;
                    all) who="a" ;;
                    *)
                        echo "❌ Invalid user group: $entity"
                        continue
                        ;;
                esac

                # Final chmod symbolic string
                if [[ "$action" == "add" ]]; then
                    $chmod_cmd "${who}+${perm}" "$target"
                    status=$?
                elif [[ "$action" == "remove" ]]; then
                    $chmod_cmd "${who}-${perm}" "$target"
                    status=$?
                else
                    echo "❌ Invalid action. Use 'add' or 'remove'."
                    continue
                fi
            fi

            perms_after=$(stat -c "%A" "$target" 2>/dev/null || echo "unknown")
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')

            if [ $status -eq 0 ]; then
                echo "✅ Permissions updated successfully."
                echo "$timestamp | User: $username | File: $target | From: $perms_before | To: $perms_after | SUCCESS" >> "$log_file"
            else
                echo "❌ Failed to update permissions."
                echo "$timestamp | User: $username | File: $target | From: $perms_before | Attempted: $perms | FAILED" >> "$log_file"
            fi
            ;;
        3)
            read -p "Enter absolute path of the directory to switch to: " new_dir

            if [ ! -d "$new_dir" ]; then
                echo "❌ Error: Directory does not exist."
                continue
            fi

            current_dir="$new_dir"
            echo "✅ Changed directory to: $current_dir"
            ;;
        4)
            echo ""
            echo "📜 Permission Change Logs:"
            if [ -f "$log_file" ]; then
                tail -n 20 "$log_file"
            else
                echo "No logs found."
            fi
            ;;
        5)
            echo "👋 Exiting. Have a nice day!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please select 1 to 5."
            ;;
    esac
done
