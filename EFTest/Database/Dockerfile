#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM postgres:16-alpine

ENV POSTGRES_USER=test_db
ENV POSTGRES_PASSWORD=test_db
ENV POSTGRES_DB=SchoolDatabase
COPY SchoolDatabase.sql /docker-entrypoint-initdb.d/
EXPOSE 5432