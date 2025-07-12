FROM mysql:8.0

# Copy initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/

# Expose port
EXPOSE 3306

# Environment variables are handled by docker-compose
