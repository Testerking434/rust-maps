# NEXUS 2500 — Hologramm-Website für Netcup

Eine komplett statische "Jahr 2500"-Cyberpunk-Website. Einfach auf deinen
Netcup-Webspace hochladen — fertig.

## Dateien

- `index.html` — Startseite
- `style.css` — Styling, Animationen, Neon-Effekte
- `script.js` — Sterne, Uhr, Typing, Boot-Log, Glitch
- `.htaccess` — Standard-Index, Kompression, Caching (Apache, bei Netcup Standard)

## Upload bei Netcup

### Variante 1: WebFTP (im Customer Control Panel / CCP)

1. In der Netcup-Verwaltung das Webhosting-Paket öffnen.
2. **WebFTP** starten.
3. In den Ordner `httpdocs/` (bzw. bei manchen Tarifen `public_html/`) wechseln.
4. Alle Dateien aus diesem Repo hochladen:
   `index.html`, `style.css`, `script.js`, `.htaccess`
5. Deine Domain im Browser öffnen — fertig.

### Variante 2: FTP-Client (FileZilla o. ä.)

- **Host:** aus Netcup-Zugangsdaten (z. B. `ftp.deinedomain.de`)
- **Port:** 21 (FTP) oder 22 (SFTP)
- **User/Passwort:** aus dem CCP
- Lokalen Ordner mit diesen Dateien → in `httpdocs/` hochladen.

### Hinweis zu `.htaccess`

Versteckte Dateien im FTP-Client sichtbar machen (z. B. FileZilla:
*Server → Versteckte Dateien anzeigen erzwingen*), sonst wird die Datei
nicht mit hochgeladen.

## Lokal testen

Einfach `index.html` im Browser öffnen. Oder ein Mini-Webserver:

```bash
python3 -m http.server 8080
```

Dann http://localhost:8080 öffnen.
