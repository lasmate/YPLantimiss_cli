#!/bin/bash

download(){
    read playlist_link
    yt-dlp --geo-bypass --yes-playlist --break-on-existing --break-per-input --downloader aria2c --format "bv*+ba/b"  playlist_link
}
log(){
    #logs the names of downloaded files to a log file
    echo "Enter the file name:"
    read logfile
    if [ -f $logfile ] ; then #check if registry exists
        echo "Log found"
    else 
        echo "file not found creating file"
        touch $logfile #create registry
    fi
    echo "logging started"
    for filename in *.webm; 
    do
        if [ -f $filename in $logfile]; then

            echo "$filename already logged"
        else
            echo "logging $filename"
            echo "$filename" >> $logfile
        fi
    done
    echo "logging finished"
}
main(){
    echo "1) Download"
    echo "2) Log"
    echo "3) #Check"
    echo "4) #Change Directory"
    echo "5) #Exit"
    read -n 1 ans1
    case $ans1 in
    1)
        download ;;
    2)
        log ;;
    3)
        check ;;
    4)
        change_dir ;;
    5)
        exit ;;
    *)
        echo "Invalid option"
        main ;;
    esac
   }
main