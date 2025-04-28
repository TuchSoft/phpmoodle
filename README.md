# Moodle Quick Test Environment

This project provides a lightweight and easy-to-use **Docker image** with an optional **Docker Compose** file to quickly spin up a Moodle instance for **development**, **testing**, or **local evaluation** purposes.  
It is designed to be simpler and faster than the official Moodle development images, with no additional testing frameworks, no FPM, and no OPcache — just **Apache + PHP** with all necessary extensions pre-installed to support **all common Moodle databases**.

>DO NOT USE IN ANY PRODUCTION ENVIROMENT
---

## Features
- Pre-installed **PHP + Apache** (no FPM, no OPcache).
- Supports **PostgreSQL**, **MySQL/MariaDB**, **SQL Server**, and **Oracle** out-of-the-box.
- Simple setup — just bind your Moodle directory.
- Docker Compose file included to easily manage services.
- Data persistence through Docker volumes.
- Exposes Moodle on port **8080** by default.
- Easy to run multiple instances simultaneously by adjusting project names and ports.

---

## Quick Start

### Using Docker Compose (recommended)

#### 1.  Download the docker-compose.yml alongside your Moodle directory

```bash
curl -o docker-compose.yml https://raw.githubusercontent.com/TuchSoft/phpmoodle/refs/heads/master/docker-compose.yml
```
or
```bash
wget docker-compose.yml https://raw.githubusercontent.com/TuchSoft/phpmoodle/refs/heads/master/docker-compose.yml
```

Make sure your Moodle codebase is available locally and ready to bind.

#### 2. Edit the `docker-compose.yml`:
    - Make sure the path to your local Moodle source (`./moodle`) is correctly set.
    - Uncomment the database block you want to use (PostgreSQL, MySQL/MariaDB, SQL Server, Oracle).

#### 3. Start the environment:
```bash
docker-compose up -d
```

---

### Using only Docker



Run the container manually:
```bash
docker run -d --name moodle-server \
  -v $(pwd)/moodle:/var/www/html \
  -p 8080:80 \
  tuchsoft/phpmoodle:latest
```

You will need to manually configure your database separately if not using Docker Compose.

---


### Access Moodle
Open your browser at:
```
http://localhost:8080
```
Follow the installation wizard, and when prompted for database settings, use:

| Database | Host | User | Password | Port |
|:---------|:-----|:-----|:---------|:-----|
| PostgreSQL | database | moodle | moodle | 5432 |
| MySQL/MariaDB | database | moodle | moodle | 3306 |
| SQL Server | database | SA | moodle | 1433 |
| Oracle | oracle | moodle | moodle | 1521 |

---

## Persistence of Data

The following volumes are defined to ensure your data is preserved across container restarts:

| Volume Name | Description |
|:------------|:------------|
| `moodle_data` | Moodle's `moodledata` directory (for file uploads, cache, etc.) |
| `db_data` | Database persistent storage |

---

## Running Multiple Instances

To run multiple Moodle test environments simultaneously:
- Duplicate your project folder.
- Edit the `docker-compose.yml`:
    - Change the `name:` field at the top.
    - Bind to **different ports** (e.g., 8081:80, 5433:5432).
- Launch both setups

---

## Notes on Database Selection

- **PostgreSQL** is enabled by default.
- To use another database:
    - Comment out the `PostgreSQL` section.
    - Uncomment the desired database section (`MySQL`, `SQL Server`, `Oracle`).

You can only enable **one** database container per instance at a time.

---

### Special Instructions for Oracle Database

Oracle DB (supported up to Moodle versions **≤ 4.4**:) requires a slight manual adjustment when installing :

- In your Moodle source folder, locate the file:
  ```
  moodle/lib/dml/oci_native_moodle_package.sql
  ```
- **Prepend** the following lines, replace occurrences of `$APP_USER` with your actual database username (typically `moodle`).
  ```sql
    CONNECT SYS/$APP_USER@FREEPDB1 AS SYSDBA;
    ALTER SESSION SET CURRENT_SCHEMA = $APP_USER;
    GRANT EXECUTE ON DBMS_LOCK TO PUBLIC;
  ```
- This step ensures correct package permissions during Oracle database initialization.

If using the provided compose setup  that's all all you need to do, an automatic initialization is attempted by mounting a custom `my-init.sql` file into the Oracle container.

---

## Troubleshooting

- **Permission issues**: Ensure the `moodle` folder and its contents have correct permissions for the container to access.
- **Ports already in use**: Change the ports in `docker-compose.yml` if needed.
- **Database connection problems**: Make sure the database service is fully initialized before starting Moodle installation.

---
> **Author:** Mattia Bonzi [[mattia@tuchsoft.com](mailto:mattia@tuchsoft.com)] | [TuchSoft OÜ](https://tuchsoft.com)  
> **License:** [MIT License](https://opensource.org/licenses/MIT)