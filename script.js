(() => {
  // Starfield
  const canvas = document.getElementById("stars");
  const ctx = canvas.getContext("2d");
  let w, h, stars;
  const STAR_COUNT = 220;

  function resize() {
    w = canvas.width = window.innerWidth;
    h = canvas.height = window.innerHeight;
    stars = Array.from({ length: STAR_COUNT }, () => ({
      x: Math.random() * w,
      y: Math.random() * h,
      z: Math.random() * 1 + 0.2,
      s: Math.random() * 1.4 + 0.2,
      hue: Math.random() < 0.15 ? 315 : Math.random() < 0.5 ? 190 : 220,
    }));
  }
  resize();
  window.addEventListener("resize", resize);

  function drawStars() {
    ctx.clearRect(0, 0, w, h);
    for (const s of stars) {
      s.y += s.z * 0.4;
      if (s.y > h) { s.y = 0; s.x = Math.random() * w; }
      ctx.beginPath();
      ctx.fillStyle = `hsla(${s.hue}, 100%, 70%, ${0.4 + s.z * 0.6})`;
      ctx.shadowBlur = 6;
      ctx.shadowColor = `hsla(${s.hue}, 100%, 70%, 1)`;
      ctx.arc(s.x, s.y, s.s, 0, Math.PI * 2);
      ctx.fill();
    }
    requestAnimationFrame(drawStars);
  }
  drawStars();

  // Clock — stardate style
  const clockEl = document.getElementById("clock");
  const coordsEl = document.getElementById("coords");
  function tick() {
    const now = new Date();
    const year = 2500;
    const pad = n => String(n).padStart(2, "0");
    const stardate = `${year}.${pad(now.getMonth() + 1)}.${pad(now.getDate())} // ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
    clockEl.textContent = `T+ ${stardate}`;
    const lat = (Math.sin(Date.now() / 4000) * 89).toFixed(3);
    const lon = (Math.cos(Date.now() / 3000) * 179).toFixed(3);
    coordsEl.textContent = `LAT ${lat} · LON ${lon}`;
  }
  tick();
  setInterval(tick, 1000);

  // Typing subtitle
  const typing = document.getElementById("typing");
  const phrases = [
    "> entschlüssle zeitlinie ...",
    "> empfange signal von sektor 07 ...",
    "> quantum-mesh stabil ✓",
    "> willkommen, reisender aus dem 21. jahrhundert.",
  ];
  let pi = 0, ci = 0, deleting = false;
  function type() {
    const cur = phrases[pi];
    typing.textContent = cur.slice(0, ci);
    if (!deleting) {
      if (ci < cur.length) { ci++; setTimeout(type, 40 + Math.random() * 40); }
      else { deleting = true; setTimeout(type, 1600); }
    } else {
      if (ci > 0) { ci--; setTimeout(type, 18); }
      else { deleting = false; pi = (pi + 1) % phrases.length; setTimeout(type, 400); }
    }
  }
  type();

  // Console boot log
  const out = document.getElementById("console-out");
  const lines = [
    "[ OK ]  uplink::netcup → handshake 200",
    "[ OK ]  quantum-mesh v25.00.01 geladen",
    "[ OK ]  hologramm-renderer aktiv",
    "[ .. ]  durchsuche chrono-index ...",
    "[ OK ]  5 einträge gefunden",
    "[ OK ]  neo-kortex synchronisiert",
    "[ ! ]  anomalie in sektor 12 — ignoriere",
    "[ OK ]  bereit.",
    "",
    "> willkommen im jahr 2500.",
    "> dies ist eine aufzeichnung.",
    "> antworten werden durch das universum verzögert.",
  ];
  let li = 0, col = 0;
  function bootLog() {
    if (li >= lines.length) return;
    const line = lines[li];
    if (col < line.length) {
      out.textContent += line[col];
      col++;
      setTimeout(bootLog, 10 + Math.random() * 25);
    } else {
      out.textContent += "\n";
      li++; col = 0;
      setTimeout(bootLog, 120);
    }
  }
  setTimeout(bootLog, 600);

  // Random glitch bursts on H1
  const h1 = document.querySelector("h1.glitch");
  setInterval(() => {
    if (Math.random() < 0.35) {
      h1.style.transform = `translate(${(Math.random()-0.5)*4}px, ${(Math.random()-0.5)*2}px) skewX(${(Math.random()-0.5)*2}deg)`;
      setTimeout(() => { h1.style.transform = ""; }, 90);
    }
  }, 1200);
})();
