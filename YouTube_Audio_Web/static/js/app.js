let currentMode = 'audio';
let currentVideoQuality = '720';
let progressInterval = null;
let isConverting = false;

// Particle background
function createParticles() {
    const container = document.getElementById('particles');
    for (let i = 0; i < 50; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.left = Math.random() * 100 + '%';
        particle.style.animationDelay = Math.random() * 15 + 's';
        particle.style.animationDuration = (Math.random() * 10 + 10) + 's';
        container.appendChild(particle);
    }
}
createParticles();

// DOM Elements
const urlInput = document.getElementById('urlInput');
const pasteBtn = document.getElementById('pasteBtn');
const audioMode = document.getElementById('audioMode');
const videoMode = document.getElementById('videoMode');
const audioOptions = document.getElementById('audioOptions');
const videoOptions = document.getElementById('videoOptions');
const bitrateSelect = document.getElementById('bitrateSelect');
const audioFormat = document.getElementById('audioFormat');
const convertBtn = document.getElementById('convertBtn');
const statusArea = document.getElementById('statusArea');
const progressFill = document.getElementById('progressFill');
const statusText = document.getElementById('statusText');
const resultArea = document.getElementById('resultArea');
const fileInfo = document.getElementById('fileInfo');
const typeDisplay = document.getElementById('typeDisplay');
const qualityDisplay = document.getElementById('qualityDisplay');
const downloadBtn = document.getElementById('downloadBtn');
const convertAnotherBtn = document.getElementById('convertAnotherBtn');
const qualityBtns = document.querySelectorAll('.quality-btn');

// Mode Switching
audioMode.addEventListener('click', () => setMode('audio'));
videoMode.addEventListener('click', () => setMode('video'));

function setMode(mode) {
    if (isConverting) return;
    currentMode = mode;
    
    if (mode === 'audio') {
        audioMode.classList.add('active');
        videoMode.classList.remove('active');
        audioOptions.style.display = 'grid';
        videoOptions.style.display = 'none';
        updateAudioInfo();
    } else {
        videoMode.classList.add('active');
        audioMode.classList.remove('active');
        audioOptions.style.display = 'none';
        videoOptions.style.display = 'block';
        updateVideoInfo();
    }
}

// Video Quality Selection
qualityBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        if (isConverting) return;
        qualityBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentVideoQuality = btn.dataset.height;
        updateVideoInfo();
    });
});

// Update Info Display
function updateAudioInfo() {
    const bitrate = bitrateSelect.value;
    const format = audioFormat.value;
    typeDisplay.textContent = 'Audio';
    qualityDisplay.textContent = `${bitrate}kbps ${format.toUpperCase()}`;
    fileInfo.style.display = 'block';
}

function updateVideoInfo() {
    const height = currentVideoQuality;
    const labels = {
        '360': 'SD (360p)',
        '480': 'SD (480p)',
        '720': 'HD (720p)',
        '1080': 'Full HD (1080p)',
        '1440': '2K (1440p)'
    };
    typeDisplay.textContent = 'Video (MP4)';
    qualityDisplay.textContent = labels[height];
    fileInfo.style.display = 'block';
}

// Event Listeners for Audio Options
bitrateSelect.addEventListener('change', () => {
    if (currentMode === 'audio') updateAudioInfo();
});

audioFormat.addEventListener('change', () => {
    if (currentMode === 'audio') updateAudioInfo();
});

// Paste Button
pasteBtn.addEventListener('click', async () => {
    try {
        const text = await navigator.clipboard.readText();
        urlInput.value = text;
        urlInput.focus();
        if (currentMode === 'audio') updateAudioInfo();
        else updateVideoInfo();
    } catch (err) {
        console.error('Clipboard access denied');
    }
});

// Convert Button
convertBtn.addEventListener('click', async () => {
    if (isConverting) return;
    
    const url = urlInput.value.trim();
    if (!url || (!url.includes('youtube.com') && !url.includes('youtu.be'))) {
        alert('Please enter a valid YouTube URL');
        return;
    }
    
    startConversion();
    
    try {
        const requestData = {
            url: url,
            type: currentMode
        };
        
        if (currentMode === 'audio') {
            requestData.format = audioFormat.value;
            requestData.quality = bitrateSelect.value;
        } else {
            requestData.format = 'mp4';
            requestData.quality = currentVideoQuality;
        }
        
        const response = await fetch('/download', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(requestData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            completeConversion(data);
        } else {
            throw new Error(data.error || 'Conversion failed');
        }
        
    } catch (error) {
        failConversion(error.message);
    }
});

function startConversion() {
    isConverting = true;
    convertBtn.disabled = true;
    convertBtn.querySelector('.btn-text').style.display = 'none';
    convertBtn.querySelector('.spinner').style.display = 'block';
    statusArea.style.display = 'block';
    resultArea.style.display = 'none';
    
    // Progress Simulation
    let progress = 0;
    progressFill.style.width = '0%';
    
    progressInterval = setInterval(() => {
        progress += Math.random() * 8;
        if (progress > 95) progress = 95;
        progressFill.style.width = progress + '%';
        
        if (progress < 30) statusText.textContent = 'Fetching video info...';
        else if (progress < 60) statusText.textContent = currentMode === 'audio' ? 'Extracting audio...' : 'Downloading video...';
        else if (progress < 90) statusText.textContent = currentMode === 'audio' ? 'Converting format...' : 'Processing video...';
    }, 600);
}

function completeConversion(data) {
    // CRITICAL FIX: Clear interval immediately
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    
    isConverting = false;
    progressFill.style.width = '100%';
    statusText.textContent = 'Complete!';
    
    setTimeout(() => {
        convertBtn.disabled = false;
        convertBtn.querySelector('.btn-text').style.display = 'block';
        convertBtn.querySelector('.spinner').style.display = 'none';
        statusArea.style.display = 'none';
        resultArea.style.display = 'block';
        
        const sizeMB = (data.size / 1024 / 1024).toFixed(1);
        document.getElementById('resultText').textContent = 
            `${data.filename} (${data.quality}) - ${sizeMB} MB`;
        
        downloadBtn.onclick = () => {
            window.location.href = `/file/${encodeURIComponent(data.filename)}`;
        };
    }, 500);
}

function failConversion(errorMsg) {
    // CRITICAL FIX: Clear interval on error too
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    
    isConverting = false;
    convertBtn.disabled = false;
    convertBtn.querySelector('.btn-text').style.display = 'block';
    convertBtn.querySelector('.spinner').style.display = 'none';
    statusArea.style.display = 'none';
    
    alert('Error: ' + errorMsg);
}

// Reset
convertAnotherBtn.addEventListener('click', () => {
    urlInput.value = '';
    resultArea.style.display = 'none';
    fileInfo.style.display = 'none';
    progressFill.style.width = '0%';
    urlInput.focus();
});

// Input detection
urlInput.addEventListener('input', () => {
    if (urlInput.value.includes('youtube.com') || urlInput.value.includes('youtu.be')) {
        if (currentMode === 'audio') updateAudioInfo();
        else updateVideoInfo();
    }
});
