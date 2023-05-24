# File-Management-
This script is a bash script that performs file management tasks based on user-defined options. It allows the user to specify a directory path, as well as choose from various file management options such as regrouping files in a specific directory, automatically deleting temporary files, and deleting unmodified files in the last 30 days.
Here's a breakdown of how the script works:
<ul>
  <li>
        The script starts by setting the config_file variable to the path of the configuration file, which is assumed to be located at "home/dhib/configuration.conf".
  </li>
  <li>
     It checks if the configuration file exists by using the [ -f "$config_file" ] condition. If the file exists, it reads the values of directory_path, REGROUP, AUTODELETE, and DELETEUNMODIFIED from the config file using the grep and cut commands.
  </li>
    <li>
    If the configuration file doesn't exist, the script prompts the user for the directory path using the zenity file selection dialog. It also presents a checklist dialog using zenity to allow the user to select file management options.

  </li>
    <li>
        The selected options are stored in the variables REGROUP, AUTODELETE, and DELETEUNMODIFIED based on the user's choices.
  </li>
    <li>
        The script creates the configuration file and saves the directory path and selected options in the format key=value
  </li>
    <li>
        If the REGROUP option is selected, the script proceeds to regroup files in a specific directory. It extracts the file extensions from the directory path using the find command and awk. Then, it creates directories for each unique file extension and moves files with the corresponding extension to the respective directories using the find and mv commands.
  </li>
    <li>
    If the AUTODELETE option is selected, the script automatically deletes log files in the /var/log directory using sudo rm.
  </li>
  
   <li>
    If the DELETEUNMODIFIED option is selected, the script finds directories in the specified directory path that were last modified more than 30 days ago using the find command with the -mtime option. It presents a list dialog box using zenity with checkboxes for each directory, allowing the user to select directories to delete.
  </li>
   
   <li>
    After the user selects directories to delete, the script displays a confirmation dialog using zenity to confirm the deletion. If the user confirms, the selected directories are deleted using the rm -rf command.
  </li>
</ul>

   

  

  .

  


