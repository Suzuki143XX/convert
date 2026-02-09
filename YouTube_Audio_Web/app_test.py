from flask import Flask, render_template, request, jsonify, send_file
from flask_cors import CORS
import yt_dlp
import os
import tempfile
import shutil
from pathlib import Path
import subprocess

app = Flask(__name__)
CORS(app)

# Downloads save to Desktop
DOWNLOAD_DIR = Path("C:/Users/gmelc/OneDrive/Desktop")

def find_ffmpeg():
    APP_DIR = Path(__file__).parent
    ffmpeg_dirs = list(APP_DIR.glob("ffmpeg/ffmpeg-*"))
    if ffmpeg_dirs:
        exe = ffmpeg_dirs[0] / "bin" / "ffmpeg.exe"
        if exe.exists():
            return str(exe)
    return shutil.which("ffmpeg")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/user')
def api_user():
    # Mock user for testing without Google auth
    return jsonify({
        'logged_in': True,
        'name': 'Guest User',
        'picture': '',
        'plan': 'free',
        'usage': {
            'mp3': {'used': 0, 'limit': 5},
            'video': {'used': 0, 'limit': 5}
        }
    })

@app.route('/download', methods=['POST'])
def download():
    data = request.json
    url = data.get('url')
    media_type = data.get('type', 'audio')
    format_type = data.get('format', 'mp3')
    quality = data.get('quality', '192')
    
    ffmpeg_path = find_ffmpeg()
    if not ffmpeg_path:
        return jsonify({'error': 'FFmpeg not found. Run the FFmpeg setup first.'}), 500
    
    temp_dir = tempfile.mkdtemp()
    
    try:
        if media_type == 'video':
            height = int(quality)
            ydl_opts = {
                'format': f'bestvideo[height<={height}]+bestaudio/best[height<={height}]',
                'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
                'merge_output_format': 'mp4',
                'postprocessors': [{'key': 'FFmpegVideoConvertor', 'preferedformat': 'mp4'}],
                'quiet': True,
            }
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                title = info.get('title', 'video')
                files = [f for f in os.listdir(temp_dir) if f.endswith(('.mp4', '.mkv', '.webm'))]
                if not files:
                    raise Exception("Download failed - no file created")
                
                output_file = os.path.join(temp_dir, files[0])
                final_name = f"{title[:50]}_{quality}p.mp4"
                final_path = DOWNLOAD_DIR / final_name
                
                counter = 1
                while final_path.exists():
                    final_name = f"{title[:50]}_{quality}p_{counter}.mp4"
                    final_path = DOWNLOAD_DIR / final_name
                    counter += 1
                
                if output_file.endswith('.mp4'):
                    shutil.move(output_file, final_path)
                else:
                    subprocess.run([ffmpeg_path, '-i', output_file, '-c:v', 'copy', '-c:a', 'aac', 
                                  '-b:a', '192k', '-movflags', '+faststart', str(final_path)], check=True)
                    os.remove(output_file)
                
                return jsonify({
                    'success': True,
                    'filename': final_name,
                    'quality': f"{quality}p MP4",
                    'type': 'video',
                    'size': os.path.getsize(final_path)
                })
        else:
            if format_type in ['flac', 'wav']:
                ydl_opts = {
                    'format': 'bestaudio/best',
                    'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
                    'postprocessors': [{'key': 'FFmpegExtractAudio', 'preferredcodec': format_type}],
                    'quiet': True,
                }
                quality_label = f"{format_type.upper()}"
            else:
                ydl_opts = {
                    'format': 'bestaudio/best',
                    'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
                    'postprocessors': [{'key': 'FFmpegExtractAudio', 'preferredcodec': format_type, 'preferredquality': quality}],
                    'quiet': True,
                }
                quality_label = f"{quality}kbps {format_type.upper()}"
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                title = info.get('title', 'audio')
                files = os.listdir(temp_dir)
                if not files:
                    raise Exception("Download failed")
                
                output_file = os.path.join(temp_dir, files[0])
                final_name = f"{title[:50]}.{format_type}"
                final_path = DOWNLOAD_DIR / final_name
                
                counter = 1
                while final_path.exists():
                    final_name = f"{title[:50]}_{counter}.{format_type}"
                    final_path = DOWNLOAD_DIR / final_name
                    counter += 1
                
                shutil.move(output_file, final_path)
                
                return jsonify({
                    'success': True,
                    'filename': final_name,
                    'quality': quality_label,
                    'type': 'audio',
                    'size': os.path.getsize(final_path)
                })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)

@app.route('/file/<path:filename>')
def serve_file(filename):
    return send_file(DOWNLOAD_DIR / filename, as_attachment=True)

if __name__ == '__main__':
    print("=" * 60)
    print("🌐 YouTube Converter Pro - TEST MODE (No Google Auth)")
    print("=" * 60)
    print("📍 Open: http://localhost:5000")
    print("💾 Downloads save to: Desktop")
    print("=" * 60)
    print("⚠️  To enable Google Login:")
    print("   1. Edit app.py and add your Google Client Secret")
    print("   2. Then restart the server")
    print("=" * 60)
    app.run(debug=False, host='0.0.0.0', port=5000)
