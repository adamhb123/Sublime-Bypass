#!/bin/bash

# Privilege check
if [ "$EUID" -ne 0 ]; then
    echo "Please run the script with sudo or as root."
    exit 1
fi


file_path="/etc/hosts"
hosts_string=$(cat << EOF
# Sublime-Bypass
0.0.0.0 sublimetext.com
0.0.0.0 sublimemerge.com
0.0.0.0 sublimehq.com
0.0.0.0 telemetry.sublimehq.com
0.0.0.0 license.sublimehq.com
0.0.0.0 45.55.255.55
0.0.0.0 45.55.41.223

EOF
)

add_hosts() {
    if grep -qF "$hosts_string" "$file_path"; then
        echo -e "Hosts file is correct.\n"
    else
        echo "$hosts_string" | cat - "$file_path" > temp && mv temp "$file_path"
        echo "Hosts successfully modified."
    fi
}

undo_hosts() {
    if grep -qzF "$hosts_string" "$file_path"; then
        escaped_hosts_string=$(echo "$hosts_string" | sed 's/[\/&]/\\&/g')
        awk -v pattern="$hosts_string" 'BEGIN{ RS="\0" } { gsub(pattern, "") } 1' "$file_path" > temp && mv temp "$file_path"
        echo "Hosts string removed from the hosts file."
    else
        echo "Hosts string not found in the hosts file. No changes made."
    fi
}


# Main program


if [ $1 ]; then
    user_input=$1
else 
    echo -e "Hosts file editor:\n\t[add] to add entries to hosts file.\n\t[undo] to remove entries from hosts file.\n\n"
    read -p ">" user_input

fi
clean_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z]//g')

case $clean_input in
    "add")
        add_hosts
        ;;
    "undo")
        undo_hosts
        ;;
    *)
        echo "Invalid input."
        ;;
esac