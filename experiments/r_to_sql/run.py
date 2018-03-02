from subprocess import run

run("sqlite3 program.db < initialize.sql".split())

run('sqlite3 program.db "SELECT * FROM scalar_integers"')
