#!/bin/bash

config_file="home/dhib/configuration.conf"

# Check if config file exists
if [ -f "$config_file" ]; then
    # Extract directory path from config file
    directory_path=$(grep "^directory_path=" "$config_file" | cut -d "=" -f 2-)
    REGROUP=$(grep "^regroup=" "$config_file" | cut -d "=" -f 2-)
    AUTODELETE=$(grep "^autodelete=" "$config_file" | cut -d "=" -f 2-)
    DELETEUNMODIFIED=$(grep "^deleteunmodified=" "$config_file" | cut -d "=" -f 2-)
else
    # If config file doesn't exist, prompt user for directory path
    REGROUP="false"
    AUTODELETE="false"
    DELETEUNMODIFIED="false"

    # Use a file selection dialog to choose the directory path
    directory_path=$(zenity --file-selection --directory --title="Select directory")

    # Use a checklist dialog to select file management options
    CHOICES=$(zenity --list --checklist \
                  --title="File Management Choices" \
                  --text="Please select one or more options:" \
                  --column="#" --column="Option" \
                  FALSE "1 Regroup files in a specific directory" \
                  FALSE "2 Automatically delete temporary files" \
                  FALSE "3 Delete unmodified files in the last 30 days" \
                  --separator=" ")

    # Set the corresponding variables based on the selected options
    for CHOICE in $CHOICES; do
        case $(echo $CHOICE | cut -d ' ' -f 1) in
            "1")
            REGROUP="yes"
            ;;
            "2")
            AUTODELETE="yes"
            ;;
            "3")
            DELETEUNMODIFIED="yes"
            ;;
        esac
    done

    # Create the config file and save the directory path and options
    echo "directory_path=$directory_path" > "$config_file"
    echo "regroup=$REGROUP" >> "$config_file"
    echo "autodelete=$AUTODELETE" >> "$config_file"
    echo "deleteunmodified=$DELETEUNMODIFIED" >> "$config_file"
fi

# Regroup files in a specific directory
if [ "$REGROUP" = "yes" ]; then
    # Extract file extensions from the directory path
    EXTENSIONS=$(find "$directory_path" -maxdepth 1 -type f | awk -F '.' '{print $NF}' | sort -u)

    # Create directories for each file extension
    for EXT in $EXTENSIONS; do
        filename="${EXT##*/}"
        extension="${filename##*.}"

        # Test if the directory already exists in the directory path
        NEW_DIR_NAME="$directory_path/$extension"
        if [ ! -d "$NEW_DIR_NAME" ]; then
            mkdir "$NEW_DIR_NAME"
        fi

        # Move files with the specific extension to the corresponding directory
        find "$directory_path" -maxdepth 1 -type f -name "*.$extension" -exec mv {} "$NEW_DIR_NAME" \;
    done
fi

# Automatically delete temporary files
if [ "$AUTODELETE" = "yes" ]; then
    # Remove log files in the /var/log directory using sudo
    sudo rm /var/log/*.log
fi

# Delete unmodified files in the last 30 days
if [ "$DELETEUNMODIFIED" = "yes" ]; then
    # Find all directories that were last modified more than 30 days ago
    dirs=$(find $directory_path -maxdepth 1 -type d -mtime +30)

    # Create a list dialog box with checkboxes for each directory
    selected_dirs=$(zenity --list --checklist --title="Select directories to delete" --column="Select" --column="Directory" --separator="\n" $(echo "$dirs" | sed 's/^/FALSE /'))

    # Confirm that the user wants to delete the selected directories
    if [ -n "$selected_dirs" ]; then
    zenity --question --title="Confirm Delete" --text="Are you sure you want to delete the selected directories?\n\n$(echo "$selected_dirs" | sed 's/^/\t- /')"
    if [ "$?" -eq "0" ]; then
        echo "$selected_dirs" | xargs -I {} rm -rf "{}"
        fi
    fi
    
fi
