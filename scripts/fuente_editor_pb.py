#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Pone una fuente MONOESPACIADA en el editor de scripts de PowerBuilder 25.

El editor venia con `EditorFontName=Tahoma`, que es proporcional: con ella
cualquier dibujo ASCII (y el banner RSRSYSTEM) sale descuadrado, porque cada
caracter mide distinto. Consolas es de ancho fijo y ademas trae los glifos de
bloque (U+2588) y de marco (U+2550...), que es justo lo que lleva el banner.

⚠️ PowerBuilder tiene que estar CERRADO: al cerrarse vuelca su copia en memoria
   encima del PB.INI y se llevaria el cambio por delante.

Uso:  python scripts/fuente_editor_pb.py            dry-run
      python scripts/fuente_editor_pb.py --aplicar
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
BACKUPS = RAIZ / ".claude" / "backups"
INI = Path(os.environ["LOCALAPPDATA"]) / "Appeon" / "PowerBuilder 25.0" / "PB.INI"

CAMBIOS = {
    "EditorFontName": "Consolas",
    "EditorFontFixed": "1",
}


def ide_abierto() -> bool:
    salida = subprocess.run(["tasklist", "/FI", "IMAGENAME eq PB250.exe"],
                            capture_output=True, text=True).stdout
    return "PB250.exe" in salida


def main() -> int:
    aplicar = "--aplicar" in sys.argv

    if not INI.exists():
        print(f"No encuentro el PB.INI: {INI}")
        return 1
    if aplicar and ide_abierto():
        print("PowerBuilder esta ABIERTO. Cierralo antes: al cerrarse pisaria el cambio.")
        return 1

    crudo = INI.read_bytes()
    texto = crudo.decode("utf-8", errors="surrogateescape")
    eol = "\r\n" if "\r\n" in texto else "\n"
    lineas = texto.split(eol)

    tocadas = 0
    for i, l in enumerate(lineas):
        if "=" not in l:
            continue
        clave = l.split("=", 1)[0].strip()
        if clave in CAMBIOS:
            nuevo = f"{clave}={CAMBIOS[clave]}"
            if nuevo != l:
                print(f"  {l}   ->   {nuevo}")
                lineas[i] = nuevo
                tocadas += 1

    if not tocadas:
        print("Ya estaba puesto, nada que cambiar.")
        return 0

    if not aplicar:
        print("\n(dry-run: nada escrito. Con --aplicar se escribe, con copia en .claude/backups)")
        return 0

    destino = BACKUPS / f"banner-{datetime.now():%Y%m%d}" / "PB.INI"
    destino.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(INI, destino)
    INI.write_bytes(eol.join(lineas).encode("utf-8", errors="surrogateescape"))
    print(f"\nHecho. Copia del original en {destino}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
