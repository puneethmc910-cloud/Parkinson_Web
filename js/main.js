// Global site logic for Parkinson’s monitoring UI

// Theme toggling using CSS custom properties
const themeToggle = document.getElementById("theme-toggle");
const rootStyle = document.documentElement.style;
let lightMode = false;
function applyTheme(light) {
  if (light) {
    rootStyle.setProperty("--bg", "#f5f7fb");
    rootStyle.setProperty("--panel", "#ffffff");
    rootStyle.setProperty("--card", "#ffffff");
    rootStyle.setProperty("--text", "#0b1021");
    rootStyle.setProperty("--muted", "#4b5563");
    rootStyle.setProperty("--accent", "#0ea5e9");
    rootStyle.setProperty("--accent-2", "#6366f1");
    rootStyle.setProperty("--danger", "#e11d48");
    rootStyle.setProperty("--ok", "#10b981");
  } else {
    rootStyle.setProperty("--bg", "#0b1021");
    rootStyle.setProperty("--panel", "#0f172a");
    rootStyle.setProperty("--card", "#111c30");
    rootStyle.setProperty("--text", "#f5f7fb");
    rootStyle.setProperty("--muted", "#9fb0c8");
    rootStyle.setProperty("--accent", "#7ef5d9");
    rootStyle.setProperty("--accent-2", "#7aa2ff");
    rootStyle.setProperty("--danger", "#ff7b9c");
    rootStyle.setProperty("--ok", "#7ef5d9");
  }
  if (themeToggle) {
    themeToggle.classList.toggle("on", light);
    themeToggle.setAttribute("aria-pressed", String(light));
  }
}
applyTheme(lightMode);
if (themeToggle) themeToggle.addEventListener("click", () => { lightMode = !lightMode; applyTheme(lightMode); });

// Contact form validation + simulated submit
const contactForm = document.getElementById("contact-form");
if (contactForm) {
  contactForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const name = contactForm.name.value.trim();
    const email = contactForm.email.value.trim();
    const message = contactForm.message.value.trim();
    if (!name || !email || !message) return alert("Please fill in all fields.");
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return alert("Enter a valid email.");
    // Placeholder: send to your backend or email service here
    try {
      await fetch("/api/contact", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ name, email, message }) });
    } catch (err) {
      console.warn("Contact submit simulated (no backend)", err);
    }
    alert("Message submitted. We'll get back to you soon.");
    contactForm.reset();
  });
}

// Dashboard logic
const page = document.body.dataset.page;
if (page === "dashboard") {
  // ESP32 BLE UUIDs
  const ESP32_SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  const SENSOR_DATA_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  const CUE_SETTINGS_CHARACTERISTIC_UUID = "2a37e651-b03d-4f15-9b82-aa473dec29e4";
  const FOG_STATUS_CHARACTERISTIC_UUID = "d2793bd4-9c3f-4a0b-9c4e-b0a7b6a4c5c2";
  const BATTERY_LEVEL_CHARACTERISTIC_UUID = "2a19";

  const statusDot = document.getElementById("status-dot");
  const statusText = document.getElementById("status-text");
  const connectBtn = document.getElementById("connect-btn");
  const disconnectBtn = document.getElementById("disconnect-btn");
  const demoBtn = document.getElementById("demo-btn");
  const protocolSelect = document.getElementById("protocol-select");
  const wsInput = document.getElementById("ws-url");
  const hostInput = document.getElementById("host-name");
  const bleServiceInput = document.getElementById("ble-service");
  const bleCharInput = document.getElementById("ble-char");
  const autoConnect = document.getElementById("autoconnect");
  const legLeftEl = document.getElementById("left-pressure");
  const legRightEl = document.getElementById("right-pressure");
  const tremorEl = document.getElementById("tremor-level");
  const hrEl = document.getElementById("hr-value");
  const tempEl = document.getElementById("temp-value");
  const tremorAlert = document.getElementById("tremor-alert");
  const pressureAlert = document.getElementById("pressure-alert");
  const vibrationAlert = document.getElementById("vibration-alert");
  const fallAlert = document.getElementById("fall-alert");
  const buzzerStatus = document.getElementById("buzzer-status");
  const ledStatus = document.getElementById("led-status");
  const dbStatus = document.getElementById("db-status");
  const dbToggle = document.getElementById("db-toggle");
  const dbClear = document.getElementById("db-clear");

  const ctxPress = document.getElementById("pressure-chart");
  const ctxTremor = document.getElementById("tremor-chart");
  const ctxVibration = document.getElementById("vibration-chart");
  const ctxHr = document.getElementById("hr-chart");
  const ctxTemp = document.getElementById("temp-chart");
  const leftLegNode = document.getElementById("left-leg-node");
  const rightLegNode = document.getElementById("right-leg-node");
  const tremorNode = document.getElementById("tremor-node");

  let ws = null;
  let reconnectTimer = null;
  let demoTimer = null;
  let bleDevice = null;
  let bleChar = null;
  let db = null;
  let dbEnabled = false;
  let buffer = [];
  const maxPoints = 240;
  let lastBeep = 0;
  const beepIntervalMs = 1200;

  const setStatus = (ok, msg) => {
    statusDot?.classList.toggle("ok", ok);
    if (statusText) statusText.textContent = msg;
  };

  // IndexedDB setup
  function initDB() {
    if (!window.indexedDB) return Promise.reject("IndexedDB not supported");
    return new Promise((resolve, reject) => {
      const req = indexedDB.open("parkinsons-monitor", 1);
      req.onupgradeneeded = (e) => {
        const dbi = e.target.result;
        if (!dbi.objectStoreNames.contains("samples")) {
          dbi.createObjectStore("samples", { keyPath: "t" });
        }
      };
      req.onsuccess = (e) => { db = e.target.result; resolve(db); };
      req.onerror = (e) => reject(e);
    });
  }
  function saveSample(d) {
    if (!db || !dbEnabled) return;
    const tx = db.transaction("samples", "readwrite");
    tx.objectStore("samples").put(d);
  }
  function clearDB() {
    if (!db) return;
    const tx = db.transaction("samples", "readwrite");
    tx.objectStore("samples").clear();
    if (dbStatus) dbStatus.textContent = "DB cleared";
  }

  const ensureChartReady = () => window.chartReady ? window.chartReady : Promise.resolve(window.Chart);

  let pressureChart, tremorChart, vibrationChart, hrChart, tempChart;
  ensureChartReady().then(() => {
    pressureChart = new Chart(ctxPress, {
      type: "line",
      data: { labels: [], datasets: [
        { label: "Left foot", data: [], borderColor: "#7ef5d9", tension: 0.1, pointRadius: 0 },
        { label: "Right foot", data: [], borderColor: "#7aa2ff", tension: 0.1, pointRadius: 0 }
      ]},
      options: { animation: false, scales: { x: { display: false }, y: { suggestedMin: 0, suggestedMax: 4095 } } }
    });
    tremorChart = new Chart(ctxTremor, {
      type: "line",
      data: { labels: [], datasets: [
        { label: "Accel magnitude (g)", data: [], borderColor: "#ffb86c", tension: 0.1, pointRadius: 0 }
      ]},
      options: { animation: false, scales: { x: { display: false }, y: { suggestedMin: 0, suggestedMax: 2 } } }
    });
    vibrationChart = new Chart(ctxVibration, {
      type: "line",
      data: { labels: [], datasets: [
        { label: "Vibration / tremor sensor", data: [], borderColor: "#f472b6", tension: 0.1, pointRadius: 0 }
      ]},
      options: { animation: false, scales: { x: { display: false }, y: { suggestedMin: 0, suggestedMax: 1024 } } }
    });
    hrChart = new Chart(ctxHr, {
      type: "line",
      data: { labels: [], datasets: [
        { label: "Heart rate (bpm)", data: [], borderColor: "#22d3ee", tension: 0.1, pointRadius: 0 }
      ]},
      options: { animation: false, scales: { x: { display: false }, y: { suggestedMin: 40, suggestedMax: 150 } } }
    });
    tempChart = new Chart(ctxTemp, {
      type: "line",
      data: { labels: [], datasets: [
        { label: "Temperature (°C)", data: [], borderColor: "#f59e0b", tension: 0.1, pointRadius: 0 }
      ]},
      options: { animation: false, scales: { x: { display: false }, y: { suggestedMin: 30, suggestedMax: 40 } } }
    });
  });

  const pushData = (chart, values) => {
    if (!chart) return;
    chart.data.labels.push("");
    chart.data.datasets.forEach((ds, i) => ds.data.push(values[i]));
    if (chart.data.labels.length > maxPoints) {
      chart.data.labels.shift();
      chart.data.datasets.forEach(ds => ds.data.shift());
    }
    chart.update("none");
  };

  const renderSample = (d) => {
    buffer.push(d);
    if (buffer.length > 600) buffer.shift();
    legLeftEl.textContent = `${d.fsrL ?? 0}`;
    legRightEl.textContent = `${d.fsrR ?? 0}`;
    const tremorMag = Math.sqrt((d.ax||0)**2 + (d.ay||0)**2 + (d.az||0)**2) - 1.0;
    tremorEl.textContent = tremorMag.toFixed(3) + " g";
    if (hrEl) hrEl.textContent = d.fogDuration ? `${d.fogDuration.toFixed(1)} s` : "-- bpm";
    if (tempEl) tempEl.textContent = d.battery ? `${d.battery}%` : "-- °C";

    const tremorHigh = Math.abs(tremorMag) > 0.12;
    tremorAlert.textContent = tremorHigh ? "Tremor elevated" : "Tremor normal";
    tremorAlert.style.color = tremorHigh ? "var(--danger)" : "var(--ok)";

    const asym = Math.abs((d.fsrL||0) - (d.fsrR||0)) / Math.max(1, ((d.fsrL||0)+(d.fsrR||0))/2);
    const imbalance = asym > 0.35;
    pressureAlert.textContent = imbalance ? "Pressure imbalance" : "Pressure balanced";
    pressureAlert.style.color = imbalance ? "var(--danger)" : "var(--ok)";

    const vib = d.vib ?? d.vibration ?? 0;
    const vibHigh = vib > 700;
    vibrationAlert.textContent = vibHigh ? "Vibration high" : "Vibration normal";
    vibrationAlert.style.color = vibHigh ? "var(--danger)" : "var(--ok)";

    const tempHigh = false; // no temp data
    const hrOut = false; // no hr data

    const fallDetected = d.fogDuration > 0;
    fallAlert.textContent = fallDetected ? "Fall detected" : "No fall detected";
    fallAlert.style.color = fallDetected ? "var(--danger)" : "var(--ok)";

    const buzzerOn = d.buzzer === true || d.buzzer === 1;
    const ledOn = d.led === true || d.led === 1;
    buzzerStatus.textContent = `Buzzer: ${buzzerOn ? "on" : "off"}`;
    ledStatus.textContent = `LED: ${ledOn ? "on" : "off"}`;
    buzzerStatus.style.color = buzzerOn ? "var(--danger)" : "var(--muted)";
    ledStatus.style.color = ledOn ? "var(--accent)" : "var(--muted)";

    pushData(pressureChart, [d.fsrL ?? 0, d.fsrR ?? 0]);
    pushData(tremorChart, [Math.max(0, tremorMag + 1)]);
    pushData(vibrationChart, [vib]);
    if (d.fogDuration) pushData(hrChart, [d.fogDuration]);
    if (d.battery) pushData(tempChart, [d.battery]);
    updateBodyMap(d, tremorMag, vib);

    const alerting = tremorHigh || imbalance || vibHigh || fallDetected || tempHigh || hrOut || buzzerOn;
    if (alerting) beepOnce();
    saveSample(d);
  };

  // Web Audio beep to mirror buzzer alert in-browser (throttled)
  let audioCtx;
  function beepOnce() {
    const now = Date.now();
    if (now - lastBeep < beepIntervalMs) return;
    lastBeep = now;
    try {
      audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.frequency.value = 880;
      gain.gain.value = 0.05;
      osc.connect(gain).connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + 0.15);
    } catch (e) {
      console.warn("Audio beep failed", e);
    }
  }

  const startDemo = () => {
    if (demoTimer) return;
    setStatus(true, "Demo mode");
    let t = 0;
    demoTimer = setInterval(() => {
      t += 20;
      const trem = Math.sin(t/120) * 0.1 + (Math.random()-0.5)*0.02;
      const sample = {
        t,
        ax: 0.02 + trem,
        ay: 0.01 + trem*0.7,
        az: 1.0 + trem*0.3,
        gx: (Math.random()-0.5)*30,
        gy: (Math.random()-0.5)*30,
        gz: (Math.random()-0.5)*30,
        fsrL: 1800 + Math.sin(t/300)*600 + Math.random()*80,
        fsrR: 1900 + Math.cos(t/320)*620 + Math.random()*80,
        vib: 500 + Math.sin(t/90)*250 + Math.random()*60,
        hr: 72 + Math.sin(t/800)*6 + Math.random()*2,
        temp: 36.6 + Math.sin(t/1500)*0.2 + (Math.random()-0.5)*0.05,
        buzzer: false,
        led: (t/1000)%2 > 1
      };
      renderSample(sample);
    }, 20);
  };
  const stopDemo = () => { if (demoTimer) clearInterval(demoTimer); demoTimer = null; };

  const cleanupWS = () => { if (ws) { ws.close(); ws = null; } if (reconnectTimer) { clearTimeout(reconnectTimer); reconnectTimer = null; } };
  const cleanupBLE = () => { if (bleDevice?.gatt?.connected) bleDevice.gatt.disconnect(); bleDevice = null; bleChar = null; };

  const connectWS = () => {
    stopDemo();
    cleanupBLE();
    cleanupWS();
    let url = wsInput.value.trim();
    if (!url && hostInput?.value) {
      const host = hostInput.value.trim();
      if (host) url = `ws://${host}:81`;
    }
    if (!url) return alert("Enter WebSocket URL for ESP32 (e.g., ws://192.168.4.1:81)");
    ws = new WebSocket(url);
    setStatus(false, "Connecting…");
    ws.onopen = () => setStatus(true, "Connected");
    ws.onclose = () => {
      setStatus(false, "Disconnected — retrying…");
      reconnectTimer = setTimeout(connectWS, 2000);
    };
    ws.onerror = () => setStatus(false, "Error — retrying…");
    ws.onmessage = (evt) => {
      try { renderSample(JSON.parse(evt.data)); }
      catch (e) { console.warn("Bad frame", e); }
    };
  };

  const connectBLE = async () => {
    stopDemo();
    cleanupWS();
    cleanupBLE();
    if (!navigator.bluetooth) return alert("Web Bluetooth not supported in this browser. Use Chromium-based with HTTPS/localhost.");
    const serviceId = bleServiceInput.value.trim() || ESP32_SERVICE_UUID;
    try {
      setStatus(false, "Scanning BLE…");
      const device = await navigator.bluetooth.requestDevice({
        acceptAllDevices: true,
        optionalServices: [serviceId]
      });
      bleDevice = device;
      const server = await device.gatt.connect();
      const service = await server.getPrimaryService(serviceId);

      // Get sensor data characteristic
      const sensorChar = await service.getCharacteristic(SENSOR_DATA_CHARACTERISTIC_UUID);
      await sensorChar.startNotifications();
      sensorChar.addEventListener("characteristicvaluechanged", (evt) => {
        try {
          const data = evt.target.value;
          const view = new DataView(data.buffer);
          const frontAvg = view.getUint16(0, true);
          const backAvg = view.getUint16(2, true);
          const batteryPercent = view.getUint8(4);
          const fogDuration = view.getFloat32(5, true);
          const sample = {
            fsrL: frontAvg,
            fsrR: backAvg,
            battery: batteryPercent,
            fogDuration: fogDuration,
            ax: 0, ay: 0, az: 1, // dummy accel
            gx: 0, gy: 0, gz: 0,
            vib: 0,
            hr: 0,
            temp: 0,
            buzzer: false,
            led: false,
            fall: false
          };
          renderSample(sample);
        } catch (e) {
          console.warn("Sensor data parse error", e);
        }
      });

      // Get FOG status characteristic
      const fogChar = await service.getCharacteristic(FOG_STATUS_CHARACTERISTIC_UUID);
      await fogChar.startNotifications();
      fogChar.addEventListener("characteristicvaluechanged", (evt) => {
        try {
          const fogDetected = evt.target.value.getUint8(0) === 1;
          fallAlert.textContent = fogDetected ? "FOG detected" : "No FOG";
          fallAlert.style.color = fogDetected ? "var(--danger)" : "var(--ok)";
        } catch (e) {
          console.warn("FOG status parse error", e);
        }
      });

      // Get battery level characteristic
      const batteryChar = await service.getCharacteristic(BATTERY_LEVEL_CHARACTERISTIC_UUID);
      await batteryChar.startNotifications();
      batteryChar.addEventListener("characteristicvaluechanged", (evt) => {
        try {
          const batteryPercent = evt.target.value.getUint8(0);
          if (tempEl) tempEl.textContent = `${batteryPercent}% battery`;
        } catch (e) {
          console.warn("Battery parse error", e);
        }
      });

      device.addEventListener("gattserverdisconnected", () => {
        setStatus(false, "BLE disconnected");
      });
      setStatus(true, "BLE connected");
    } catch (err) {
      console.warn("BLE connect failed", err);
      setStatus(false, "BLE error");
      alert("BLE connect failed. Check service/characteristic UUIDs and HTTPS.");
    }
  };

  const disconnectWS = () => {
    stopDemo();
    if (reconnectTimer) clearTimeout(reconnectTimer);
    reconnectTimer = null;
    if (ws) ws.close();
    ws = null;
    setStatus(false, "Disconnected");
  };
  const disconnectBLE = () => {
    stopDemo();
    cleanupBLE();
    setStatus(false, "Disconnected");
  };

  const connectByMode = () => {
    const mode = protocolSelect?.value || "wifi";
    if (mode === "ble") connectBLE(); else connectWS();
  };
  const disconnectByMode = () => {
    const mode = protocolSelect?.value || "wifi";
    if (mode === "ble") disconnectBLE(); else disconnectWS();
  };

  function mapColor(val, maxVal) {
    const t = Math.max(0, Math.min(1, val / maxVal));
    const r = Math.round(126 + t * (255 - 126));
    const g = Math.round(245 - t * 120);
    const b = Math.round(217 - t * 160);
    return `rgb(${r},${g},${b})`;
  }
  function updateBodyMap(d, tremorMag, vib) {
    if (leftLegNode) leftLegNode.setAttribute("fill", mapColor(d.fsrL || 0, 3000));
    if (rightLegNode) rightLegNode.setAttribute("fill", mapColor(d.fsrR || 0, 3000));
    if (tremorNode) {
      const tVal = Math.abs(tremorMag) + (vib || 0) / 1500;
      tremorNode.setAttribute("fill", mapColor(tVal, 0.6));
    }
  }

  connectBtn?.addEventListener("click", connectByMode);
  disconnectBtn?.addEventListener("click", disconnectByMode);
  demoBtn?.addEventListener("click", () => { demoTimer ? stopDemo() : startDemo(); });
  dbToggle?.addEventListener("click", async () => {
    if (!db) await initDB().catch(() => alert("DB init failed"));
    dbEnabled = !dbEnabled;
    if (dbStatus) dbStatus.textContent = dbEnabled ? "DB: recording" : "DB: idle";
    dbToggle.textContent = dbEnabled ? "Pause DB" : "Save to DB";
  });
  dbClear?.addEventListener("click", clearDB);

  if (autoConnect?.checked) connectByMode();
}

// Simple smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener("click", (e) => {
    const target = document.querySelector(a.getAttribute("href"));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: "smooth" });
    }
  });
});

