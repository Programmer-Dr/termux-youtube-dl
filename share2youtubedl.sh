#!/bin/bash
clear

DOWNLOAD_PATH="~/storage/shared/Download/"
PLAYLIST="%(extractor)s/%(uploader)s/%(playlist_title)s/%(playlist_autonumber)03d_%(title)s.%(ext)s"
PLAYLIST2="%(extractor)s/%(uploader)s/%(playlist_title)s/%(playlist_autonumber)03d_%(title)s.%(ext)s"
CHANNEL="%(extractor)s/channel_%(uploader)s/%(channel_id)s/%(playlist_title)s/%(playlist_autonumber)03d_%(title)s.%(ext)s"
CONFIG_PATH="${HOME}/.config/yt-dlp/"

#PLAYLISTId=$(yt-dlp --no-config --flat-playlist --print "%(playlist_id)s" $1|tail -1)
#VIDEOId=$(yt-dlp --no-config --flat-playlist --print "%(id)s" $1|tail -1)
#PLAYLISTId=$(yt-dlp --no-config --print "%(playlist_id)s" $1)
#VIDEOId=$(yt-dlp --no-config --print "%(id)s" $1)
#YoutubeID=$(echo $1|grep -oP '(?:(https:\/\/|http:\/\/)?(?:www\.)?(?:(?<=youtu)?\.?(?<=be)?(?<=\.com)?)(?<=\/)?(?<=playlist\?list=)?)([0-9A-Za-z_-]*)'|tail -1)
if  echo $1|grep -P "(?:$|(http\:\/\/|https\:\/\/)+|(?:www\.)+(?:youtu)+\.?(?:be)+.+)(?:playlist)+|(?:list=)+.*"; then YoutubeID=$(yt-dlp --no-config --print "%(playlist_id)s" --playlist-end 1 $1); else YoutubeID=$(yt-dlp --no-config --print "%(id)s" $1); fi
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
# echo "Current Time : $CURRENT_TIME"

function echo_bold() { echo -ne "\033[0;1;34m${*}${NC}\n"; }
function echo_success() { echo -ne "\033[1;32m${*}${NC}\n"; }
function echo_warning() { echo -ne "\033[1;33m${*}${NC}\n"; }
function echo_danger() { echo -ne "\033[1;31m${*}${NC}\n"; }
function echo_error() { echo -ne "\033[0;1;31merror:\033[0;31m\t${*}${NC}\n"; }

function isSponsorblockAlive() {
    #* HTTP/2 400 = bad request = api is working 1
    #* HTTP/2 200 = ok = api is working 1
    #! HTTP/2 404 = not found = api is not working 0
    #! HTTP/2 500 = internal server error = api is not working 0
    res=$(curl -Is https://sponsor.ajay.app/api/skipSegments | grep "HTTP" | awk '{print $2}')
    if [ "$res" == "200" ] || [ "$res" == "400" ]; then
        echo_success "sponsorblock api is working"
        return 1
    else
        echo_warning "sponsorblock api is not working"
        return 0
    fi
}

function downloadVideo() {
    echo -e "\\nDownloading video...\\n"
    yt-dlp --config-locations "${CONFIG_PATH}config" -F "$1"
    echo_warning "Choose your video quality (<enter> for: 'best'):"
    read -p "" video
    echo_warning "Choose your audio quality (<enter> for: 'best'):"
    read -p "" audio
    echo_warning "Input video name:"
    read -p "" name

    if [[ "$video" = "" ]]; then
        video="best"
    fi
    if [[ "$audio" = "" ]]; then
        audio="best"
    fi
    if [[ "$name" = "" ]]; then
        name="%(extractor)s/%(uploader)s_%(title).40s [%(id)s].%(ext)s"
    fi
    if isSponsorblockAlive; then
        # sucess
        yt-dlp --config-locations "${CONFIG_PATH}sponsorblock.conf" -o "$name" -f "$video"+"$audio" "$1"
    else
        # fail
        yt-dlp --config-locations "${CONFIG_PATH}config" -o "$name" -f "$video"+"$audio" "$1"
    fi
}

function downloadChannel() {
    echo "Downloading channel..."
    if isSponsorblockAlive; then
        yt-dlp --config-locations "${CONFIG_PATH}sponsorblock.conf" -o "$CHANNEL" "$1"
    else
        yt-dlp --config-locations "${CONFIG_PATH}config" -o "$CHANNEL" "$1"
    fi
}

function downloadPlaylist() {
    echo "Downloading playlist..."
    QUALITYheightMAX=$2
    QUALITYheightMIN=$3
    QUALITYwidthMAX=$4
    QUALITYwidthMIN=$5
    QUALITYtbr=$6
    QUALITYheightMAX2=$7
    QUALITYheightMIN2=$8
    QUALITYwidthMAX2=$9
    QUALITYwidthMIN2=${10}
    QUALITYtbr2=${11}
    QUALITYheightMAX3=${12}
    QUALITYheightMIN3=${13}
    QUALITYwidthMAX3=${14}
    QUALITYwidthMIN3=${15}
    QUALITYtbr3=${16}
    if isSponsorblockAlive; then
        yt-dlp --config-locations "${CONFIG_PATH}sponsorblock.conf" -f "bestvideo[height=?${QUALITYheightMAX}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[height=?${QUALITYheightMAX2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX2}][height>${QUALITYheightMIN2}][vcodec=vp9][tbr<=${QUALITYtbr2}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX2}][height>${QUALITYheightMIN2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX2}][width>${QUALITYwidthMIN2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX2}][width>${QUALITYwidthMIN2}][vcodec=vp9][tbr<=${QUALITYtbr2}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX2}][width>${QUALITYwidthMIN2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[height=?${QUALITYheightMAX3}][tbr<=${QUALITYtbr3}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX3}][height>${QUALITYheightMIN3}][vcodec=vp9][tbr<=${QUALITYtbr3}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX3}][height>${QUALITYheightMIN3}][tbr<=${QUALITYtbr3}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX3}][width>${QUALITYwidthMIN3}][tbr<=${QUALITYtbr3}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX3}][width>${QUALITYwidthMIN3}][vcodec=vp9][tbr<=${QUALITYtbr3}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX3}][width>${QUALITYwidthMIN3}][tbr<=${QUALITYtbr3}]+bestaudio" -P $DOWNLOAD_PATH -o "$PLAYLIST" "$1"
    else
        yt-dlp --config-locations "${CONFIG_PATH}config" -f "bestvideo[height=?${QUALITYheightMAX}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[height=?${QUALITYheightMAX2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX2}][height>${QUALITYheightMIN2}][vcodec=vp9][tbr<=${QUALITYtbr2}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX2}][height>${QUALITYheightMIN2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX2}][width>${QUALITYwidthMIN2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX2}][width>${QUALITYwidthMIN2}][vcodec=vp9][tbr<=${QUALITYtbr2}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX2}][width>${QUALITYwidthMIN2}][tbr<=${QUALITYtbr2}]+bestaudio/bestvideo[height=?${QUALITYheightMAX3}][tbr<=${QUALITYtbr3}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX3}][height>${QUALITYheightMIN3}][vcodec=vp9][tbr<=${QUALITYtbr3}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX3}][height>${QUALITYheightMIN3}][tbr<=${QUALITYtbr3}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX3}][width>${QUALITYwidthMIN3}][tbr<=${QUALITYtbr3}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX3}][width>${QUALITYwidthMIN3}][vcodec=vp9][tbr<=${QUALITYtbr3}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX3}][width>${QUALITYwidthMIN3}][tbr<=${QUALITYtbr3}]+bestaudio" -P $DOWNLOAD_PATH -o "$PLAYLIST" "$1"
    fi

}


function downloadAudio() {
    echo "Downloading audio..."
    if isSponsorblockAlive; then
        yt-dlp --config-locations "${CONFIG_PATH}sponsorblock.conf" -P $DOWNLOAD_PATH -o "$PLAYLIST" -x "$1"
    else
        yt-dlp --config-locations "${CONFIG_PATH}config" -P $DOWNLOAD_PATH -o "$PLAYLIST" -x "$1"
    fi
}

function downloadAudioQua() {
    echo "Downloading audio..."
    EXTENSIONN=$2
    if isSponsorblockAlive; then
        yt-dlp --config-locations "${CONFIG_PATH}sponsorblock.conf" -P $DOWNLOAD_PATH -f "bestaudio[acodec=${EXTENSIONN}]/bestaudio[ext =${EXTENSIONN}]/bestaudio[EXT=${EXTENSIONN}]" -o "$PLAYLIST"  "$1"
    else
        yt-dlp --config-locations "${CONFIG_PATH}config" -P $DOWNLOAD_PATH -f "bestaudio[acodec=${EXTENSIONN}]/bestaudio[ext=${EXTENSIONN}]/bestaudio[EXT=${EXTENSIONN}]" -o "$PLAYLIST" "$1"
    fi
}

# If shared element is a youtube link
if [[ "$1" =~ ^.*youtu.*$ ]] || [[ "$1" =~ ^.*youtube.*$ ]]; then
    echo_bold "Downloading...\\n>URL: ${1}"
    echo_warning "Choose between the following options:"
    echo_bold "1. Video mode (choose quality and name)"
    echo_bold "2. Playlist Mode 720p"
    echo_bold "3. Playlist Mode 480p"
    echo_bold "4. Playlist mode 360p"
    echo_bold "5. Playlist mode 240p"
    echo_bold "6. Channel mode"
    echo_bold "7. Audio only mode"

    echo_warning "Enter your choice:"
    read -p "" choice

    case $choice in
    1)
        downloadVideo "$1" 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    2)
        downloadPlaylist "$1" 720 680 1280 1100 1555 1080 900 1920 1800 3333 480 400 854 799 777 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt" 
        ;;
    3)
        downloadPlaylist "$1" 480 400 854 799 777 720 680 1280 1100 1555 360 300 640 599 555 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    4)
        downloadPlaylist "$1" 360 300 640 599 555 480 400 854 799 777 240 200 426 399 333 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    5)
        downloadPlaylist "$1" 240 200 426 399 333 360 300 640 599 555 188 144 210 200 150 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    6)
        downloadChannel "$1" 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    7)
        downloadAudio "$1" 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    *)
        echo_error "\\nInvalid choice!\\n"
        ;;
    esac

# If shared element is a soundcloud link
elif [[ "$1" =~ ^.*sound.*$ ]] || [[ "$1" =~ ^.*soundclound.*$ ]] || [[ "$1" =~ ^.*sndcdn.*$ ]]; then
    echo_bold "Downloading...\\n>URL: ${1}"
    echo_warning "Choose between the following options:"
    echo_bold "1. Sound mode (Best quality)"
    echo_bold "2. Playlist Mode mp3"
    echo_bold "3. Playlist Mode opus"
    echo_bold "4. Playlist mode wav"
    echo_warning "Enter your choice:"
    read -p "" choice

    case $choice in
    1)
        downloadAudio "$1" 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    2)
        downloadAudioQua "$1" mp3 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    3)
        downloadAudioQua "$1" opus 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    4)
        downloadAudioQua "$1" wav 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
        ;;
    *)
        echo_error "\\nInvalid choice!\\n"
        ;;
    esac


# Weird case i don't know when it happens
elif [[ "$1" =~ ^.*nourlselected.*$ ]]; then
    echo "There was an error"


# If shared element is NOT a youtube/SoundCloud link
else
    yt-dlp --config-locations "${CONFIG_PATH}config" -f "bestvideo[height<=?360][height>299][vcodec=vp9]+bestaudio[acodec=opus]/bestvideo[height<=?360][height>299]+bestaudio/bestvideo[height<=?480][height>360]+bestaudio/bestvideo[height<=?720][height>480]+bestaudio/bestvideo+bestaudio" -P $DOWNLOAD_PATH -o "$PLAYLIST2" "$1" 2>&1 | tee "${CONFIG_PATH}log/${YoutubeID}.${CURRENT_TIME}.txt"
fi

read -p "Press enter to continue"
