@echo off
echo Installing required packages...
python -m pip install flask yt-dlp flask-cors -q
echo.
echo Starting YouTube Audio Converter...
echo Opening http://localhost:5000
start http://localhost:5000
python app.py
pause
