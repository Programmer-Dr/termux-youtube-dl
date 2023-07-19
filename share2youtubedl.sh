#!/bin/bash
clear

DOWNLOAD_PATH="~/storage/shared/Download/"
PLAYLIST="%(extractor)s/%(uploader)s/%(playlist_title)s_%(playlist_id)s/%(playlist_autonumber)03d_%(title)s.%(ext)s"
PLAYLIST2="%(extractor)s/%(uploader)s/%(playlist_title)s_%(playlist_id)s/%(playlist_autonumber)03d_%(title)s.%(ext)s"
CHANNEL="%(extractor)s/channel_%(uploader)s/%(channel_id)s/%(playlist_title)s_%(playlist_id)s/%(playlist_autonumber)03d_%(title)s.%(ext)s"
CONFIG_PATH="${HOME}/.config/yt-dlp/"

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
    if isSponsorblockAlive; then
        yt-dlp --config-locations "${CONFIG_PATH}sponsorblock.conf" -f "bestvideo[height=?${QUALITYheightMAX}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio" -P $DOWNLOAD_PATH -o "$PLAYLIST" "$1"
    else
        yt-dlp --config-locations "${CONFIG_PATH}config" -f "bestvideo[height=?${QUALITYheightMAX}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[height<=?${QUALITYheightMAX}][height>${QUALITYheightMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][vcodec=vp9][tbr<=${QUALITYtbr}]+bestaudio[acodec=opus]/bestvideo[width<=?${QUALITYwidthMAX}][width>${QUALITYwidthMIN}][tbr<=${QUALITYtbr}]+bestaudio" -P $DOWNLOAD_PATH -o "$PLAYLIST" "$1"
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
        downloadVideo "$1"
        ;;
    2)
        downloadPlaylist "$1" 720 680 1280 1100 900
        ;;
    3)
        downloadPlaylist "$1" 480 400 854 799 777
        ;;
    4)
        downloadPlaylist "$1" 360 300 640 599 555
        ;;
    5)
        downloadPlaylist "$1" 240 200 426 399 333
        ;;
    6)
        downloadChannel "$1"
        ;;
    7)
        downloadAudio "$1"
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
        downloadAudio "$1"
        ;;
    2)
        downloadAudioQua "$1" mp3
        ;;
    3)
        downloadAudioQua "$1" opus
        ;;
    4)
        downloadAudioQua "$1" wav
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
    yt-dlp --config-locations "${CONFIG_PATH}config" -f "bestvideo[height<=?360][vcodec=vp9]+bestaudio[acodec=opus]/bestvideo[height<=?360]+bestaudio/bestvideo[height<=?480]+bestaudio/bestvideo[height<=?720]+bestaudio/bestvideo+bestaudio" -P $DOWNLOAD_PATH -o "$PLAYLIST2" "$1"
fi

read -p "Press enter to continue"
