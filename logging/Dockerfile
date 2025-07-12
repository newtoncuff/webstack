FROM grafana/loki:3.0.0

# Create necessary directories
USER root
RUN mkdir -p /loki/chunks /loki/rules /loki/index && \
    chown -R loki:loki /loki

# Copy configuration
COPY config/loki.yml /etc/loki/local-config.yaml

# Switch back to loki user
USER loki

# Expose ports
EXPOSE 3100 9095

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3100/ready || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/bin/loki"]
CMD ["-config.file=/etc/loki/local-config.yaml"]
