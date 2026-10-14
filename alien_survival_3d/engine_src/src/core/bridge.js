// Messages from the engine to the Flutter shell. In Flutter the WebView injects
// a JavaScript channel named `GameBridge`; in a desktop browser the messages are
// kept in window.__bridgeLog so tests can assert on them.

window.__bridgeLog = window.__bridgeLog || [];

export function send(type, data = {}) {
  const msg = JSON.stringify({ type, ...data });
  window.__bridgeLog.push(msg);
  if (window.__bridgeLog.length > 200) window.__bridgeLog.shift();
  try {
    if (window.GameBridge && typeof window.GameBridge.postMessage === 'function') {
      window.GameBridge.postMessage(msg);
    }
  } catch (e) {
    // Never let a bridge failure break the frame loop.
  }
}

export const hasHost = () => !!(window.GameBridge && window.GameBridge.postMessage);
