FROM mcr.microsoft.com/playwright/python:v1.44.0-jammy

# Install Node.js, Nginx, and gettext-base (for envsubst)
RUN apt-get update && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs nginx gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cache-bust: force fresh copy every build
ARG CACHE_DATE=2026-07-16
COPY . /app

# Install all Python dependencies
RUN pip install --no-cache-dir \
    -r /app/fb-auto-poster/requirements.txt \
    -r /app/fb-commenter-v2/requirements.txt \
    -r /app/fb_buyers_egypt/requirements.txt \
    -r /app/rekomnd_plus/requirements.txt \
    -r /app/whatsapp-bulk-sender/whatsapp-bulk-sender/backend/requirements.txt

# Install Node dependencies and Playwright browsers
RUN cd /app/whatsapp-bulk-sender/wa-server && npm install && \
    playwright install --with-deps chromium

# Configure Nginx
RUN cp /app/nginx.conf.template /etc/nginx/nginx.conf.template && \
    cp /app/start.sh /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
