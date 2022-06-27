#!/bin/bash

Defaultdir="D:\VIDEO\YTarchive"



download_all(){
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

check_all(){
    #Parse/scrapes given playlist for all item if not present in download folder adds an entry to the registry and asks if download is allowed
    #If yes downloads and add a row to registry
    #If not add a row to registry and mark as "excluded"
    #If after -c item from the registry are missing from online parse call -dm  ,
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
    mark_missing()


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

}
main(argv,playlist_link) {
    #main script, checks arguments and calls the appropriate function
    #Base options :
        #-d (download all)
        #-dn(download new)
        #-c (check all)
        #-dc(ReDownload all and check all)
        #-mm(mark_missing)
        #-dir(change Download and check directory)

        #ytdlp 
    if [ $# -eq 0 ]; then
        echo "No arguments provided"
        echo "Usage: $0 -d -dn -c -dc -mm -dir"
        exit 1
    fi
    if [ $# -gt 1 ]; then
        echo "Too many arguments provided"
        echo "Usage: $0 -d -dn -c -dc -mm -dir"
        exit 1
    fi
    if [ $# -eq 1 ]; then
        if [ $1 == "-d" ]; then
            download_all
        elif [ $1 == "-dn" ]; then
            download_new
        elif [ $1 == "-c" ]; then
            check_all
        elif [ $1 == "-dc" ]; then
            download_all
            check_all
        elif [ $1 == "-mm" ]; then
            mark_missing
        elif [ $1 == "-dir" ]; then
            change_dir
        else
            echo "Invalid argument"
            echo "Usage: $0 -d -dn -c -dc -mm -dir"
            exit 1
        fi
    fi


}