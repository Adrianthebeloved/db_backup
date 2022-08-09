#!/usr/bin/bash

set -e
echo -e "\n>>> Resetting the database"
./manage.py reset_db --close-sessions --noinput

# Assuming local machine is logged in to remote DB server via ssh

# Environment variables to specify
# the target database and login credentials.

#check
export PGHOST=64.227.1.219
export PGPORT=''
export PGDATABASE=wyre_db
export PGUSER=wyreuser
export PGPASSWORD=wyre1234

# descriptive file name + timestamp to give dump descriptive name
# Eg. postgres_wyre_db_1591255548.pgdump
TIME=$(date "+%s")
BACKUP_FILE="postgres_${PGDATABASE}_${TIME}.pgdump"

# writing the pg_dump into the backup-file using custom 
# format which is ~3x smaller in size than regular SQL
echo -e "Backing up $PGDATABASE to $BACKUP_FILE"
pg_dump --format=custom > $BACKUP_FILE
echo -e "Backup completed"


# Used pg_restore to restore the database from backup_file 
# and name with the pgdatabase name stored 
# in the environmental variables
echo -e "\nRestoring database from backup"
pg_restore --dbname $PGDATABASE $BACKUP_FILE

echo -e "\n>>> Running migrations"
./manage.py migrate

echo -e "\n>>> Creating new superuser 'wyreuser'"
./manage.py createsuperuser \
   --username wyreuser \
   --email wyreuser@example.com \ #check
   --noinput

echo -e "\n>>> Setting superuser 'wyreuser' password to wyre1234"
./manage.py shell_plus --quiet-load -c "
u=User.objects.get(username='wyreuser')
u.set_password('wyre1234')
u.save()
"

echo -e "\n>>> Database restore finished."