#!/bin/bash
echo "Hello World"

download(){
    read playlist_link
    yt-dlp --geo-bypass --yes-playlist --break-on-existing --break-per-input --downloader aria2c --format "bv*+ba/b"  $playlist_link
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
    for filename in *.webm; #loop through all files with .webm extension
    do
        if grep -Fxq "$filename" $logfile; #check if file is already in registry
        then
            echo "$filename already logged" #if file is already in registry skip
        else
            echo "logging $filename" 
            echo "$filename" >> $logfile #if file is not in registry add to registry
        fi
    done
    echo "logging finished"
}
check(){
    #checks if logged files are still available online
    #if not adds "OFFLINE - " to the beginning of the file name
    echo "Enter the logfile name:"
    read logfile
    if [ -f $logfile ] ; then #check if registry exists
        echo "Log found"
    else 
        echo "no file found"
        exit 1
    fi
    echo "checking started"
    while read -r  line; do #loop through all lines in registry
        if yt-dlp --geo-bypass --break-on-existing --downloader aria2c --format "bv*+ba/b" $line; then #check if file is still available online
            echo "$line is online" #if file is online skip
        else
            echo "$line is offline" #if file is offline adds "OFFLINE" to the file
            mv "$line.webm" "OFFLINE - $line.webm"
        fi
    done < $logfile
    echo "checking finished"

}
menu_main(){
    echo "1) Download"
    echo "2) Log new files"
    echo "3) Check"
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

main(){
    while getopts "d:l:c:" opt; do
        case $opt in
            d)
                download 
                ;;
            l)
                log 
                ;;
            c)
                check 
                ;;
            m)
                menu_main
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                exit 1
                ;;
        esac
    done
   }

main