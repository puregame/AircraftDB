## Aircraft Database

This project is based on the Dump1090 project, it uses an array of raspberry Pis running a modified version of Dump1090 to collect information on airplanes currently flying overhead.

# Dependancies:
In order for this project to work some dependancies must be installed. The database and API code does not need to be run on the same server, in which case 1&2 will be installed on the database server, and 3-5 will be installed on the API server.

1. [PostgreSQL](http://www.postgresql.org/)
2. [PostGIS](http://postgis.net/)
3. [Python 2.7](https://www.python.org/)
4. [Bottle](http://bottlepy.org/docs/dev/index.html)
5. [Psycopg2](http://initd.org/psycopg/)