# -*- coding: utf-8 -*-
"""Comprueba que la BD de la demo tiene lo que la API necesita.

Lee SIEMPRE las credenciales del .env de la carpeta de la charla: no hay
ningun dato de conexion escrito en este fichero.

Uso:  python datos/comprobar_bd_demo.py
"""
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent

# Lo que la API de 2024 da por supuesto que existe
TABLAS = ['nomregistro', 'Usuarios_mobile']
PROCEDIMIENTOS = ['fichar']


def leer_env() -> dict:
    env = {}
    fichero = RAIZ / '.env'
    if not fichero.exists():
        print('ERROR: no existe', fichero)
        sys.exit(1)
    for linea in fichero.read_text(encoding='utf-8').splitlines():
        linea = linea.strip()
        if not linea or linea.startswith('#') or '=' not in linea:
            continue
        clave, valor = linea.split('=', 1)
        env[clave.strip()] = valor.strip()
    faltan = [c for c in ('DEMO_DB_HOST', 'DEMO_DB_NAME', 'DEMO_DB_USER', 'DEMO_DB_PASSWORD')
              if not env.get(c)]
    if faltan:
        print('ERROR: faltan estas claves en el .env:', ', '.join(faltan))
        sys.exit(1)
    return env


def main() -> int:
    import pyodbc

    env = leer_env()
    servidor = '%s,%s' % (env['DEMO_DB_HOST'], env.get('DEMO_DB_PORT', '1433'))
    cadena = (
        'DRIVER={ODBC Driver 17 for SQL Server};'
        f"SERVER={servidor};DATABASE={env['DEMO_DB_NAME']};"
        f"UID={env['DEMO_DB_USER']};PWD={env['DEMO_DB_PASSWORD']};"
        'TrustServerCertificate=yes;'
    )
    print('Conectando a %s / %s ...' % (servidor, env['DEMO_DB_NAME']))
    try:
        cn = pyodbc.connect(cadena, timeout=10)
    except pyodbc.Error as ex:
        # Si la base pedida no existe, al menos decir cuales hay en ese servidor
        print('No se pudo abrir la base de datos:', ex.args[-1] if ex.args else ex)
        maestra = cadena.replace(
            "DATABASE=%s;" % env['DEMO_DB_NAME'], 'DATABASE=master;')
        try:
            cn = pyodbc.connect(maestra, timeout=10)
            cur = cn.cursor()
            cur.execute('select name from sys.databases order by name')
            print('')
            print('Bases de datos en %s:' % servidor)
            for (nombre,) in cur.fetchall():
                print('   ', nombre)
            cn.close()
        except Exception as ex2:
            print('Tampoco se pudo entrar a master:', ex2)
        return 1
    cur = cn.cursor()

    problemas = []

    for tabla in TABLAS:
        cur.execute(
            "select count(*) from sys.objects where name = ? and type in ('U','V')", tabla)
        if cur.fetchone()[0] == 0:
            problemas.append('FALTA la tabla/vista %s' % tabla)
        else:
            cur.execute('select count(*) from [%s]' % tabla)
            print('  OK  %-16s %8d filas' % (tabla, cur.fetchone()[0]))

    for proc in PROCEDIMIENTOS:
        cur.execute(
            "select count(*) from sys.objects where name = ? and type = 'P'", proc)
        estado = 'OK ' if cur.fetchone()[0] else 'FALTA'
        print('  %s procedimiento %s' % (estado, proc))
        if estado.strip() == 'FALTA':
            problemas.append('FALTA el procedimiento almacenado %s' % proc)

    # Que empleados hay para poder entrar en la demo
    try:
        cur.execute('select top 10 usuario, empresa, empleado, grupo, activo from Usuarios_mobile')
        print('\n  Usuarios de la demo:')
        for fila in cur.fetchall():
            print('   ', ' | '.join(str(c).strip() if c is not None else '' for c in fila))
    except Exception as ex:
        print('  (no se pudo leer Usuarios_mobile:', ex, ')')

    cn.close()

    if problemas:
        print('\nPROBLEMAS:')
        for p in problemas:
            print(' -', p)
        return 1

    print('\nTodo lo que la API necesita esta en la base de datos.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
