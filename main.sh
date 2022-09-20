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
check_all(){
    #Parse/scrapes given playlist for all item if not present in download folder adds an entry to the registry and asks if download is allowed
    #If yes downloads and add a row to registry
    #If not add a row to registry and mark as "excluded"
    #If after -c item from the registry are missing from online parse call -dm  ,
    if [ -f registry.txt ]; then //check if registry exists
        echo "Registry found"
    else
        echo "Registry not found"
        touch registry.txt //create registry
    fi
    ytdlp --flat-playlist "playlist_link">tempregistry.txt
    for row in $(cat tempregistry.txt);
    do
        if grep -q "$row" registry.txt;
        then
            echo "Found $row all is good "
        else
            echo "Not found $row marking as offline_only"
            $row >> missingregistry.txt
        fi 
    done

}



main(){
    #main script, checks arguments and calls the appropriate function
    #Base options :
    #-d (download all)
    #-dn(download new)
    #-c (check all)
    #-dc(ReDownload all and check all)
    #-mm(mark_missing)
    #-dir(change Download and check directory)
    while getopts "d:dn:c:dc:mm:dir:" opt; do
        case $opt in
            d)
                download_all $OPTARG # done in test.sh
                ;;
            dn)
                download_new $OPTARG # partially done in test.sh, mix of download/log/check
                ;;
            c)
                check_all $OPTARG #done in test.sh renamed to log
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
            \?)
                echo "Invalid option: -$OPTARG" >&2
                echo "Usage: $0 -d(download all) -dn(download new) -c(check all) -dc(redownload all and check all) -mm(mark missing) -dir(change directory)"
                ;;
        esac
    done 
    #ytdlp 
}
main