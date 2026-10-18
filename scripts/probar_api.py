# -*- coding: utf-8 -*-
"""Prueba de humo de la API de la demo, de punta a punta.

Recorre el mismo camino que hara PowerBuilder en la charla:
    login -> ticket de un solo uso -> canje -> leer fichajes -> fichar.

El puerto sale del .env y el usuario de prueba de la propia tabla
(FicharDemoApi/Database/usuarios_mobile.json). No imprime nunca un PIN.
El fichaje de prueba se borra al terminar: los datos quedan como estaban.

Uso:  python scripts/probar_api.py
"""
import json
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
USUARIOS = RAIZ / 'FicharDemoApi' / 'Database' / 'usuarios_mobile.json'


def leer_env() -> dict:
    env = {}
    for linea in (RAIZ / '.env').read_text(encoding='utf-8').splitlines():
        linea = linea.strip()
        if linea and not linea.startswith('#') and '=' in linea:
            clave, valor = linea.split('=', 1)
            env[clave.strip()] = valor.strip()
    return env


def usuario_de_prueba():
    """El primer usuario activo de la tabla de usuarios."""
    usuarios = json.loads(USUARIOS.read_text(encoding='utf-8'))
    fila = next((u for u in usuarios if u.get('activo')), None)
    if not fila:
        print('ERROR: no hay ningun usuario activo en', USUARIOS)
        sys.exit(1)
    return [str(fila[c]).strip() for c in ('Usuario', 'Pin', 'empresa', 'empleado')]


def llamar(url, cuerpo=None, token=None, metodo=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    peticion = urllib.request.Request(url, data=datos, method=metodo or ('POST' if datos else 'GET'))
    peticion.add_header('Content-Type', 'application/json')
    if token:
        peticion.add_header('Authorization', 'Bearer ' + token)
    try:
        with urllib.request.urlopen(peticion, timeout=20) as r:
            texto = r.read().decode('utf-8')
            return r.status, (json.loads(texto) if texto else None)
    except urllib.error.HTTPError as ex:
        return ex.code, ex.read().decode('utf-8', 'ignore')


def main() -> int:
    env = leer_env()
    # 127.0.0.1 y no localhost: Python prueba antes ::1 (IPv6), la API solo
    # escucha en IPv4 y cada llamada se comia 2 segundos de espera.
    base = 'http://127.0.0.1:%s/api' % env.get('DEMO_API_PORT', '5080')
    usuario, pin, empresa, empleado = usuario_de_prueba()
    print('Usuario de prueba: %s (empresa %s, empleado %s)\n' % (usuario, empresa, empleado))

    fallos = 0

    # 1. Sin token, todo cerrado
    codigo, _ = llamar('%s/Auth/Me' % base)
    ok = codigo == 401
    print('  %s  sin token -> %s (se espera 401)' % ('OK ' if ok else 'MAL', codigo))
    fallos += 0 if ok else 1

    # 2. Login (lo que hara PowerBuilder)
    codigo, r = llamar('%s/Auth/Login' % base,
                       {'username': usuario, 'password': pin, 'origen': 'PB'})
    if codigo != 200:
        print('  MAL login ->', codigo, r)
        return 1
    token_pb = r['token']
    print('  OK  login -> 200, token de %d caracteres, origen=%s' % (len(token_pb), r.get('origen')))

    # 3. PowerBuilder pide el ticket de un solo uso
    codigo, r = llamar('%s/Auth/Ticket' % base, {}, token=token_pb)
    if codigo != 200:
        print('  MAL ticket ->', codigo, r)
        return 1
    ticket = r['ticket']
    print('  OK  ticket -> 200, vive %s segundos' % r['expiraSegundos'])

    # 4. La web lo canjea por SU token
    codigo, r = llamar('%s/Auth/Redeem' % base, {'ticket': ticket})
    if codigo != 200:
        print('  MAL canje ->', codigo, r)
        return 1
    token_web = r['token']
    print('  OK  canje  -> 200, la web entra como %s sin teclear la clave' % r.get('usuario'))

    # 5. El ticket es de UN solo uso
    codigo, _ = llamar('%s/Auth/Redeem' % base, {'ticket': ticket})
    ok = codigo == 401
    print('  %s  el mismo ticket otra vez -> %s (se espera 401)' % ('OK ' if ok else 'MAL', codigo))
    fallos += 0 if ok else 1

    # 6. Con el token de la web, leer los fichajes de hoy
    hoy = date.today().isoformat()
    url_hoy = '%s/Nomregistro/Retrieve/%s/%s/%s' % (base, empresa, empleado, hoy)
    codigo, antes = llamar(url_hoy, token=token_web)
    if codigo != 200:
        print('  MAL fichajes ->', codigo, antes)
        return 1
    print('  OK  fichajes de hoy -> 200, %d registros' % len(antes))

    # 7. Fichar: se graba en el JSON y aparece al volver a leer
    codigo, r = llamar('%s/Nomregistro/Fichar' % base,
                       {'empresa': empresa, 'empleado': empleado, 'latitud': 0, 'longitud': 0},
                       token=token_web)
    _, despues = llamar(url_hoy, token=token_web)
    nuevos = [f for f in despues if f['No'] not in {a['No'] for a in antes}]
    ok = codigo == 200 and len(nuevos) == 1
    print('  %s  fichar -> %s, %d fichaje nuevo (se espera 1)' % ('OK ' if ok else 'MAL', codigo, len(nuevos)))
    fallos += 0 if ok else 1

    # 8. Se borra el de prueba: los datos quedan como estaban
    for f in nuevos:
        llamar('%s/Nomregistro/BorrarFichaje' % base, {'id': f['No']}, token=token_web)
    _, final = llamar(url_hoy, token=token_web)
    ok = len(final) == len(antes)
    print('  %s  borrar el de prueba -> quedan %d (se esperan %d)' % ('OK ' if ok else 'MAL', len(final), len(antes)))
    fallos += 0 if ok else 1

    print('\n%s' % ('TODO CORRECTO.' if fallos == 0 else '%d COMPROBACIONES FALLIDAS.' % fallos))
    return 0 if fallos == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
