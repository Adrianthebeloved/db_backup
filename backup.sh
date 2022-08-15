#!/usr/bin/bash

set -e
echo -e "\n>>> setting credentials to environment"

# Assuming local machine is logged in to remote DB server via ssh

# Environment variables to specify-
# the target database and login credentials.
export PGHOST=104.248.238.213
export PGPORT=5432
export PGDATABASE=wyre_db
export PGUSER=wyreuser
export PGPASSWORD=wyre1234

# descriptive file name + timestamp to give dump descriptive name
# Eg. postgres_wyre_db_1591255548.pgdump
echo -e "\n>>> getting the backup"
TIME=$(date "+%s")
BACKUP_FILE="postgres_${PGDATABASE}_${TIME}.pgdump"


# writing the pg_dump into the backup-file using custom 
# format which is ~3x smaller in size than regular SQL
echo -e "Backing up $PGDATABASE to $BACKUP_FILE"
pg_dump --format=custom > $BACKUP_FILE
echo -e "Backup completed"


# Used pg_restore to restore the database from backup_file-
# and name with the pgdatabase name stored-
# in the environmental variables
echo -e "\nRestoring database from backup"
pg_restore -h localhost -U wyreuser -O -c -C --dbname=wyre_db $BACKUP_FILE
echo -e "\nRestore complete"

echo -e "\n>>> Running migrations"
./manage.py makemigrations
./manage.py migrate

echo -e "\n>>> Creating new superuser 'wyreuser'"
./manage.py createsuperuser \
   --username wyreuser \
   --email wyreuser@example.com \
   --noinput

echo -e "\n>>> Setting superuser 'wyreuser' password to 'wyre1234'"
./manage.py shell --quiet-load -c "
u=User.objects.get(username='wyreuser')
u.set_password('wyre1234')
u.save()
"

echo -e "\n>>> Database restore finished."