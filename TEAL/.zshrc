alias ytdl-video="youtube-dl -i --external-downloader aria2c --external-downloader-args '-c -j 16 -x 16 -s 16 -k 1M'"
alias ytdl-music="youtube-dl --external-downloader aria2c --external-downloader-args '-c -j 16 -x 16 -s 16 -k 1M' -f bestaudio --audio-quality 0 --audio-format flac -i -x --extract-audio"
