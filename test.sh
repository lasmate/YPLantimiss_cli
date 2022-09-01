
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
    if [ -f registry.txt ]; then #check if registry exists
        echo "Registry found"
    else
        echo "Registry not found"
        touch registry.txt #create registry
    fi
    ytdlp --flat-playlist "playlist_link">tempregistry.txt
    for row in $(cat tempregistry.txt);
    do
        if grep -q "$row" registry.txt;
        then
            echo "Found $row all is good ";
        else
            echo "Not found $row marking as offline_only";
            $row >> missingregistry.txt;
        fi
    done
    mark_missing()
}
    
mark_missing(){
    #change name of said  files to have "offline_only" at the end of them and had a red colored cell on registry
    for row in $(cat missingregistry.txt);
    do 
        sed 's/# $row/$row offline_only/' registry.txt;
        
    done   
}

change_dir(){
    #Dire arg given next to it to set the diff directory and then launch -c to check the state of the dirt and possible fils already being here 
}

