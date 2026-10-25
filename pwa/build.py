"""Monta o PWA em _site/ a partir de preview/index.html (fonte única das telas).

Uso: python3 pwa/build.py [versão]
"""
import re
import shutil
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "_site"
version = sys.argv[1] if len(sys.argv) > 1 else str(int(time.time()))

source = (ROOT / "preview" / "index.html").read_text(encoding="utf-8")

# O script vai para um arquivo separado, para a CSP bloquear qualquer script inline.
match = re.search(r"<script>(.*?)</script>", source, re.S)
if not match:
    sys.exit("preview/index.html sem <script>")
script = match.group(1)
body = source[: match.start()] + source[match.end():]
title = re.search(r"<title>.*?</title>", body, re.S).group(0)
body = body.replace(title, "", 1)
body = re.sub(r'<meta name="(claude:viewport-fit-sides|apple-mobile-web-app-[^"]*|theme-color)"[^>]*>\n?', "", body)

register = """
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("./sw.js").catch(() => {});
}
"""

page = f"""<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; manifest-src 'self'; worker-src 'self'; base-uri 'none'; form-action 'none'; object-src 'none'">
<meta name="referrer" content="no-referrer">
{title}
<meta name="theme-color" content="#f2f4f3" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0b0f0d" media="(prefers-color-scheme: dark)">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="Finanças">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">
<style>
  :root {{ color-scheme: light dark; padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }}
  html, body {{ margin: 0; }}
</style>
</head>
<body>
{body.strip()}
<script src="app.js"></script>
</body>
</html>
"""

if OUT.exists():
    shutil.rmtree(OUT)
(OUT / "icons").mkdir(parents=True)
(OUT / "index.html").write_text(page, encoding="utf-8")
(OUT / "app.js").write_text(script.strip() + "\n" + register, encoding="utf-8")
sw = (ROOT / "pwa" / "sw.js").read_text(encoding="utf-8").replace("__VERSION__", version)
(OUT / "sw.js").write_text(sw, encoding="utf-8")
shutil.copy(ROOT / "pwa" / "manifest.webmanifest", OUT)
for icon in (ROOT / "pwa" / "icons").glob("*.png"):
    shutil.copy(icon, OUT / "icons")
(OUT / ".nojekyll").write_text("")
print(f"PWA gerado em {OUT} (versão {version})")
