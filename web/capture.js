let captureStream = null;
let captureInterval = null;

async function startWebCapture(settings) {
  const fps = settings && settings.fps ? settings.fps : 3;
  try {
    captureStream = await navigator.mediaDevices.getDisplayMedia({ video: true });
    const video = document.createElement('video');
    video.srcObject = captureStream;
    await video.play();

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    const sendFrame = () => {
      if (!video.videoWidth) return;
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      const png = canvas.toDataURL('image/png');
      window.postMessage({ type: 'verzus_frame', base64: png.split(',')[1], timestamp: Date.now() }, '*');
    };

    captureInterval = setInterval(sendFrame, 1000 / Math.max(1, fps));
  } catch (err) {
    console.error('startWebCapture err', err);
  }
}

function stopWebCapture() {
  if (captureInterval) clearInterval(captureInterval);
  captureInterval = null;
  if (captureStream) {
    captureStream.getTracks().forEach(t => t.stop());
    captureStream = null;
  }
}

window.startWebCapture = startWebCapture;
window.stopWebCapture = stopWebCapture;
