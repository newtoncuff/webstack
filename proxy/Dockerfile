FROM nginx:alpine

# Install bash and gettext for the entrypoint script and envsubst
RUN apk add --no-cache bash gettext

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy and make executable the entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create directories for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Expose ports
EXPOSE 80 443

# Use custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
