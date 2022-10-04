#way too complicated, refactor all, make it more readable
echo "echo"

#!/bin/bash

Defaultdir="D:\VIDEO\YTarchive"


download(){

    echo "Enter the playlist link:"
    read playlist_link
    yt-dlp --geo-bypass --yes-playlist --break-on-existing --break-per-input --downloader aria2c --format "bv*+ba/b"  $playlist_link
}

download_new(){ #need to revactor it to use the same function as download
    #Checks if item is already downloaded
    #If not downloads and add entry to registry 
    ytdlp --flat-playlist "playlist_link">tempregistry.txt
    for row in $(cat registry.txt);
    do
        if grep -q "$row" tempregistry.txt;
        then
            echo "Found $row keeping it "
        else
            echo "Not found $row downloading it"
            yt-dlp --geo-bypass  --download-archive registry.txt --downloader aria2c -path D/VIDEO/YTarchive/$3 --format "bv*+ba/b"  $row 
            $row >> registry.txt
        fi
    done
}

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

while getopts "d:dn:l:dc:c:h" opt; do
    case $opt in
        d)
            download_all $OPTARG # done in test.sh
            ;;
        dn)
            download_new $OPTARG # partially done in test.sh, mix of download/log/check
            ;;
        l)
            log $OPTARG
            ;;
        dc)
            download_all $OPTARG # partially done , must add a force redownload and force relog option
            log $OPTARG
            ;;
        c)
            check $OPTARG #done in test.sh renamed check
            ;;
            ;;
        h)

            echo "Usage: $0 [-d] [-dn] [-l] [-dc] [-c] [-dir] [-h]"
            echo "  -d  Download all"
            echo "  -dn Download new"
            echo "  -l log newly downloaded files"
            echo "  -dl ReDownload all and check all"
            echo "  -c check all and mark missing"
            echo "  -h  Help"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Usage: $0 -d(download all) -dn(download new) -c(check) -dc(redownload all and check all)  -dir(change directory)"
            ;;
    esac
done 
#ytdlp 
