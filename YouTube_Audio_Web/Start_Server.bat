@echo off
echo Checking FFmpeg...
if not exist "ffmpeg\ffmpeg-*" (
    echo FFmpeg not found! Run Setup_FFMPEG.ps1 first
    pause
    exit
)
echo Starting server...
start http://localhost:5000
python app.py
pause
