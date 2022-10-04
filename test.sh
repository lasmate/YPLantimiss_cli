#!/bin/bash

download(){
    read playlist_link
    yt-dlp --geo-bypass --yes-playlist --break-on-existing --break-per-input --downloader aria2c --format "bv*+ba/b"  $playlist_link
}

log(){
    #logs the names of downloaded files to a log file
    if [$OPTARG != ""]; then
        echo "Enter the file name:"
        read logfile
    else
        echo "file name alredy provided"
        logfile=$OPTARG
    fi
    if [ -f $logfile ] ; then #check if registry exists
        echo "Log found"
    else 
        echo "file not found creating file"
        touch $logfile #create registry
    fi
    echo "logging started"
    default_dir 
    for filename in *.webm ; #loop through all files with .webm extension
    do
        if grep -Fxq "$filename" ../$logfile; #check if file is already in registry
        then
            echo "$filename already logged" #if file is already in registry skip
        else
            echo "logging $filename" 
            echo "$filename" >> ../$logfile #if file is not in registry add to registry
        fi
    done
    cd ../
    echo "logging finished"
}

check(){
    #checks if logged files are still available online
    #if not adds "OFFLINE - " to the beginning of the file name
    if [$OPTARG != ""]; then #check if file name is provided  
    #ok wait wtf it works but why, it should ask for a filename if none is provided from getopts but it does not 
        echo "Enter the file name:"
        read logfile
    else
        echo "file name alredy provided"
        logfile=$OPTARG
    fi
    if [ -f $logfile ] ; then #check if registry exists
        echo "Log found"
    else 
        echo "no file found"
        exit 1
    fi
    echo "checking started"
    while read -r line; do #loop through all lines in registry
        #only takes the code within brackets from the line and stores it in a variable
        # exammple of single video link https://www.youtube.com/watch?v=CYkvfsnEKe0&
        video_id=$(echo $line | grep -oP '(?<=\[).*(?=\])')
        FineLine= "$video_id"
        echo $FineLine
        if yt-dlp --geo-bypass --break-on-existing https://www.youtube.com/watch?v=$video_id ; #check if file is still available online
        then
            echo "$line is online" #if file is online skip
        else
            echo "$line is offline" #if file is offline adds "OFFLINE" to the file
            mv "$line" "OFFLINE - $line"
        fi
    done < $logfile
    echo "checking finished"
}



menu_main(){
    echo "1) Download" #done
    echo "2) Log new files" #done
    echo "3) Check" #done
    echo "4) #Change Directory"
    echo "5) Exit"
    read -n 1 ans1
    case $ans1 in
    1)
        download ;;
    2)
        log  
        ;;
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
    menu_main
}

main