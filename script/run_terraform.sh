#!/bin/bash

# Get the absolution of path
abs_path_file_execute=$(realpath "$0")
abs_path_folder_script=$(dirname "$abs_path_file_execute")
abs_path_folder_root=$(dirname "$(dirname "$abs_path_file_execute")")
abs_path_folder_terraform="$abs_path_folder_root""/terraform/modules/vm/"


# Bash Menu Script Example
echo "---------MENU------------"
PS3='Please enter your choice: '
options=("Create virtual machine" "Destroy virtual machine" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Create virtual machine")
            cd $abs_path_folder_terraform
            terraform init
            terraform plan 
            terraform apply -auto-approve
        ;;
        "Destroy virtual machine")
            cd $abs_path_folder_terraform
            terraform destroy -auto-approve
        ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
