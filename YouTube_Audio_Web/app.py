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

DOWNLOAD_DIR = Path("C:/Users/gmelc/OneDrive/Desktop/YouTube_Downloads")
DOWNLOAD_DIR.mkdir(exist_ok=True)

APP_DIR = Path(__file__).parent
FFMPEG_PATH = None

def find_ffmpeg():
    global FFMPEG_PATH
    ffmpeg_dirs = list(APP_DIR.glob("ffmpeg/ffmpeg-*"))
    if ffmpeg_dirs:
        bin_path = ffmpeg_dirs[0] / "bin"
        ffmpeg_exe = bin_path / "ffmpeg.exe"
        if ffmpeg_exe.exists():
            FFMPEG_PATH = str(ffmpeg_exe)
            return FFMPEG_PATH
    if shutil.which("ffmpeg"):
        FFMPEG_PATH = "ffmpeg"
        return FFMPEG_PATH
    return None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    data = request.json
    url = data.get('url')
    media_type = data.get('type', 'audio')
    format_type = data.get('format', 'mp3')
    quality = data.get('quality', '192')
    
    if not url:
        return jsonify({'error': 'No URL provided'}), 400
    
    ffmpeg_path = find_ffmpeg()
    if not ffmpeg_path:
        return jsonify({'error': 'FFmpeg not found'}), 500
    
    temp_dir = tempfile.mkdtemp()
    try:
        if media_type == 'video':
            # FIXED: Better video format selection with audio merge
            height = int(quality)
            
            # Format: best video with audio, or merge separate streams
            # Prefer mp4 container for compatibility
            format_spec = f'bestvideo[height<={height}][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<={height}]+bestaudio/best[height<={height}]'
            
            ydl_opts = {
                'format': format_spec,
                'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
                'ffmpeg_location': os.path.dirname(ffmpeg_path),
                'merge_output_format': 'mp4',
                # FIXED: Add postprocessor to ensure audio is merged
                'postprocessors': [{
                    'key': 'FFmpegVideoConvertor',
                    'preferedformat': 'mp4',
                }],
                'quiet': True,
                'verbose': False,
            }
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                title = info.get('title', 'video')
                
                # Find the final merged file
                files = [f for f in os.listdir(temp_dir) if f.endswith(('.mp4', '.mkv', '.webm', '.m4a'))]
                if not files:
                    raise Exception("Video download failed")
                
                # Get the largest file (should be the merged one with both video+audio)
                output_file = max([os.path.join(temp_dir, f) for f in files], key=os.path.getsize)
                
                # If it's not mp4, convert it
                final_name = f"{title[:50]}_{quality}p.mp4"
                final_path = DOWNLOAD_DIR / final_name
                
                counter = 1
                while final_path.exists():
                    final_name = f"{title[:50]}_{quality}p_{counter}.mp4"
                    final_path = DOWNLOAD_DIR / final_name
                    counter += 1
                
                # If file is already mp4, move it. Otherwise, ffmpeg convert it
                if output_file.endswith('.mp4'):
                    shutil.move(output_file, final_path)
                else:
                    # Convert to mp4 with audio using ffmpeg directly
                    cmd = [
                        ffmpeg_path, '-i', output_file, 
                        '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k',
                        '-movflags', '+faststart',
                        str(final_path)
                    ]
                    subprocess.run(cmd, check=True)
                    os.remove(output_file)
                
                return jsonify({
                    'success': True,
                    'filename': final_name,
                    'path': str(final_path),
                    'quality': f"{quality}p MP4",
                    'type': 'video',
                    'size': os.path.getsize(final_path)
                })
        
        else:
            # Audio logic remains the same
            if format_type in ['flac', 'alac', 'wav']:
                ydl_opts = {
                    'format': 'bestaudio/best',
                    'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': format_type,
                    }],
                    'ffmpeg_location': os.path.dirname(ffmpeg_path),
                    'quiet': True,
                }
                quality_label = f"{format_type.upper()} Lossless"
            else:
                ydl_opts = {
                    'format': 'bestaudio/best',
                    'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': format_type,
                        'preferredquality': quality,
                    }],
                    'ffmpeg_location': os.path.dirname(ffmpeg_path),
                    'quiet': True,
                }
                quality_label = f"{quality}kbps {format_type.upper()}"
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                title = info.get('title', 'audio')
                
                files = os.listdir(temp_dir)
                if not files:
                    raise Exception("Audio download failed")
                
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
                    'path': str(final_path),
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
    ffmpeg = find_ffmpeg()
    if ffmpeg:
        print(f"✅ FFmpeg: {ffmpeg}")
    else:
        print("⚠️  FFmpeg not found")
    print(f"🌐 http://localhost:5000")
    print(f"📁 {DOWNLOAD_DIR}")
    app.run(debug=False, host='0.0.0.0', port=5000)
