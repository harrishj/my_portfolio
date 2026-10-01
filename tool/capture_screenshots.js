const { spawn } = require('child_process');
const fs = require('fs');

async function main() {
  const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
  const debugPort = 9222;

  const chromeProcess = spawn(chromePath, [
    '--headless=new',
    '--disable-gpu',
    `--remote-debugging-port=${debugPort}`,
    '--no-first-run',
    '--no-default-browser-check',
    'about:blank',
  ]);

  let endpoint = null;
  for (let i = 0; i < 20; i++) {
    await new Promise(r => setTimeout(r, 500));
    try {
      const res = await fetch(`http://127.0.0.1:${debugPort}/json/version`);
      const data = await res.json();
      endpoint = data.webSocketDebuggerUrl;
      if (endpoint) break;
    } catch (_) {}
  }

  const ws = new WebSocket(endpoint);
  await new Promise(r => ws.onopen = r);

  let id = 1;
  const callbacks = new Map();
  ws.onmessage = (event) => {
    const msg = JSON.parse(event.data);
    if (msg.id && callbacks.has(msg.id)) {
      callbacks.get(msg.id)(msg);
      callbacks.delete(msg.id);
    }
  };

  function send(method, params = {}) {
    return new Promise((resolve) => {
      const currentId = id++;
      callbacks.set(currentId, resolve);
      ws.send(JSON.stringify({ id: currentId, method, params }));
    });
  }

  const { result: { targetId } } = await send('Target.createTarget', { url: 'http://localhost:8080' });
  const pageWs = new WebSocket(`ws://127.0.0.1:${debugPort}/devtools/page/${targetId}`);
  await new Promise(r => pageWs.onopen = r);

  let pageId = 1;
  const pageCallbacks = new Map();
  pageWs.onmessage = (event) => {
    const msg = JSON.parse(event.data);
    if (msg.id && pageCallbacks.has(msg.id)) {
      pageCallbacks.get(msg.id)(msg);
      pageCallbacks.delete(msg.id);
    }
  };

  function sendPage(method, params = {}) {
    return new Promise((resolve) => {
      const currentId = pageId++;
      pageCallbacks.set(currentId, resolve);
      pageWs.send(JSON.stringify({ id: currentId, method, params }));
    });
  }

  await sendPage('Page.enable');

  await sendPage('Emulation.setDeviceMetricsOverride', {
    width: 375,
    height: 812,
    deviceScaleFactor: 1,
    mobile: true,
  });

  await new Promise(r => setTimeout(r, 5000));

  // Scroll down 40 times to reach the bottom contact section on mobile
  for (let i = 0; i < 40; i++) {
    await sendPage('Input.dispatchMouseEvent', {
      type: 'mouseWheel',
      x: 180,
      y: 400,
      deltaX: 0,
      deltaY: 500,
    });
    await new Promise(r => setTimeout(r, 60));
  }
  await new Promise(r => setTimeout(r, 1500));

  const contactSnap = await sendPage('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync('screenshot_mobile_contact.png', Buffer.from(contactSnap.result.data, 'base64'));
  console.log('Saved screenshot_mobile_contact.png!');

  pageWs.close();
  ws.close();
  chromeProcess.kill();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
