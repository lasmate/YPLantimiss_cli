#way too complicated, refactor all, make it more readable


#!/bin/bash

Defaultdir="D:\VIDEO\YTarchive"


download_all(){
    read $2
    #use ytdlp to download all the videos in the playlist and add all their titles to a text file(possibly scv?)
    yt-dlp --geo-bypass --yes-playlist --download-archive registry.txt --break-on-existing  --break-per-input --downloader aria2c -path Defaultdir/$3 --format "bv*+ba/b"  $2
    
}

download_new(){
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
mark_missing(){
    #change name of said  files to have "offline_only" at the end of them and had a red colored cell on registry
    for row in $(cat missingregistry.txt);
    do 
        sed 's/# $row/$row offline_only/' registry.txt
        
    done
    
}
change_dir(){
    #Dire arg given next to it to set the diff directory and then launch -c to check the state of the dirt and possible fils already being here 
    echo "State new directory"
    read -p "Enter new directory: " newdir
    if [ -d "$newdir" ]; then
        echo "Directory exists"
        Defaultdir=$newdir
    else
        echo "Directory does not exist"
        Defaultdir=$newdir
        mkdir $newdir
    fi
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



main(){
    while getopts "d:dn:l:dc:mm:dir:" opt; do
        case $opt in
            d)
                download_all $OPTARG # done in test.sh
                ;;
            dn)
                download_new $OPTARG # partially done in test.sh, mix of download/log/check
                ;;
            l)
                log 
                ;;
            dc)
                download_all $OPTARG # partially done , must add a force redownload and force relog option
                check_all $OPTARG
                ;;
            mm)
                mark_missing $OPTARG #done in test.sh renamed check
                ;;
            dir)
                change_dir $OPTARG
                ;;
            h)

                echo "Usage: $0 [-d] [-dn] [-l] [-dc] [-mm] [-dir] [-h]"
                echo "  -d  Download all"
                echo "  -dn Download new"
                echo "  -l log newly downloaded files"
                echo "  -dc ReDownload all and check all"
                echo "  -mm Mark missing"
                echo "  -dir Change Download and check directory"
                echo "  -h  Help"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                echo "Usage: $0 -d(download all) -dn(download new) -c(check all) -dc(redownload all and check all) -mm(mark missing) -dir(change directory)"
                ;;
        esac
    done 
    #ytdlp 
}
main