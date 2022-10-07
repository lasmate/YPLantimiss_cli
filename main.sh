#!/bin/bash
# would be nite to implement a laylist cache fonction/ add the plylist link at he top of the 
default_dir(){
    if [ -d DLD ]; then
        echo "Directory found"
    else
        echo "Directory not found"
        mkdir DLD
    fi
    cd DLD
    echo "Directory changed"
}

log(){
    #logs the names of downloaded files to a log file
    logfile=$OPTARG
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
    logfile=$OPTARG
    if [ -f $logfile ] ; then #check if registry exists
        echo "Log found"
    else 
        echo "file not found exiting"
        exit 1
    fi
    echo "checking started"
    while read -r line; do #loop through all lines in registry
        #only takes the code within brackets from the line and stores it in a variable
        # exammple of single video link https://www.youtube.com/watch?v=CYkvfsnEKe0&
        video_id=$(echo $line | grep -oP '(?<=\[).*(?=\])')
        FineLine= "$video_id"
        echo $FineLine
        if [yt-dlp --geo-bypass --break-on-existing https://www.youtube.com/watch?v=$video_id == 0 ] ; #check if file is still available online
        then
            echo "$line is online" #if file is online skip
            mv "$line" "ONLINE - $line"
        else
            echo "$line is offline" #if file is offline adds "OFFLINE" to the file
            mv "$line" "OFFLINE - $line"
        fi
    done < $logfile
    echo "checking finished"
}

download(){
    if [ $autolog == 2 ]; then
        echo "Enter the file name:"
        read logfile
        echo "Enter the playlist link:"
        read playlist_link
        printf $playlist_link >> $logfile
    else
        echo "Enter the playlist link:"
        read playlist_link
    fi
    echo "downloading started"
    default_dir
    yt-dlp --geo-bypass --yes-playlist --break-on-existing --break-per-input --downloader aria2c --format "bv*+ba/b"  $playlist_link
    cd ../
}

download_new(){ 
    #Checks if item is already downloaded ,If not downloads and add entry to registry 
    echo "Enter logfile name:"
    read logfile
    if [ -f $logfile ] ; then #check if registry exists
        echo "Log found"
    else 
        echo "file not found exiting"
        exit 1
    fi
    echo "checking $logfile for youtube link"
    playlist_link=$(cat $logfile | head -n 1)
    #add a valid string test to playlist_link

    echo "playlist link found"
    default_dir
    echo "downloading started"
    yt-dlp --geo-bypass --yes-playlist --break-on-existing --break-per-input --downloader aria2c --format "bv*+ba/b"  $playlist_link
    cd ../
    log
}



while getopts "d:D:l:c:h" opt; do
    case $opt in
        d)
            echo "1)simple download"
            echo "2)logged download"
            read autolog
            download $OPTARG # done in test.sh
            ;;
        D)
            download_new # nearly done in main.sh lacks some guardrails
            ;;
        l)
            log $OPTARG
            ;;
        #dc)
            #download_all $OPTARG # partially done , must add a force redownload and force relog option
            #;;
        c)
            check $OPTARG #done in test.sh renamed check
            ;;
        h)
            echo "Usage: $0 [-d] [-dn] [-l] [-dc] [-c] [-dir] [-h]"
            echo "  -d  Download all"
            echo "  -D Download new"
            echo "  -l log newly downloaded files"
            #echo "  -dl ReDownload all and check all"
            echo "  -c check all and mark missing"
            echo "  -h  Help"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Usage: $0 -d(download all) -dn(download new) -c(check) -dc(redownload all and check all)  -dir(change directory)"
            ;;
    esac
done