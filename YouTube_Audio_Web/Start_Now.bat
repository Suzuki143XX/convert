@echo off
echo =======================================
echo  YouTube Converter Pro - Starting...
echo =======================================
echo.
cd /d "C:\Users\gmelc\OneDrive\Desktop\YouTube_Audio_Web"
echo [1/2] Checking dependencies...
python -m pip install flask flask-cors yt-dlp -q
echo [2/2] Starting server...
echo.
echo The website will open automatically
echo.
timeout /t 2 >nul
start http://localhost:5000
python app_test.py
pause
