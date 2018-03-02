next="0"
last="2"

while [ $next != $last ]
do
    next=$(sqlite3 program.db < $next.sql)
done

echo "loop finished."

sqlite3 program.db "SELECT * FROM scalar_integers"
