FROM mcr.microsoft.com/playwright/python:v1.44.0-jammy

# Install Node.js, Nginx, and gettext-base (for envsubst)
RUN apt-get update && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs nginx gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cache buster - change this value to force Railway to rebuild from scratch
ARG CACHE_DATE=2026071603
COPY . /app

# Install Python dependencies one by one to isolate errors
RUN pip install --no-cache-dir -r /app/rekomnd_plus/requirements.txt || true
RUN pip install --no-cache-dir -r /app/fb-auto-poster/requirements.txt || true
RUN pip install --no-cache-dir -r /app/fb-commenter-v2/requirements.txt || true
RUN pip install --no-cache-dir -r /app/fb_buyers_egypt/requirements.txt || true
RUN pip install --no-cache-dir -r /app/whatsapp-bulk-sender/whatsapp-bulk-sender/backend/requirements.txt

# Install Node dependencies and Playwright browsers
RUN cd /app/whatsapp-bulk-sender/wa-server && npm install
RUN playwright install --with-deps chromium || true

# Configure Nginx
RUN cp /app/nginx.conf.template /etc/nginx/nginx.conf.template
RUN cp /app/start.sh /start.sh && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
