FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=admin
ENV MYSQL_DATABASE=olympic_participation

COPY ./tables.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
