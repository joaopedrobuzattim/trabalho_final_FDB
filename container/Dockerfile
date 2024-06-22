FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=admin

COPY ./start_USA.sql /docker-entrypoint-initdb.d/
COPY ./start_CHINA.sql /docker-entrypoint-initdb.d/


EXPOSE 3306
