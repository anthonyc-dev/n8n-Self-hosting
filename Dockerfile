# ===========================================
# Production Dockerfile for n8n
# ===========================================
# Extends the official n8n image with production settings

FROM n8nio/n8n:latest

# Environment variables for production
ENV NODE_ENV=production \
    N8N_LOG_LEVEL=info \
    N8N_LOG_OUTPUT=console \
    EXECUTIONS_DATA_PRUNE=true \
    EXECUTIONS_DATA_MAX_AGE=168 \
    N8N_METRICS=true \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Health check configuration
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5678/healthz', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Expose n8n port
EXPOSE 5678
