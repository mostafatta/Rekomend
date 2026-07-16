FROM mcr.microsoft.com/playwright/python:v1.44.0-jammy

# Install Node.js, Nginx, and gettext-base (for envsubst)
RUN apt-get update && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs nginx gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy all requirements first for caching
COPY fb-auto-poster/requirements.txt /app/fb-auto-poster/
COPY fb-commenter-v2/requirements.txt /app/fb-commenter-v2/
COPY fb_buyers_egypt/requirements.txt /app/fb_buyers_egypt/
COPY rekomnd_plus/requirements.txt /app/rekomnd_plus/
COPY whatsapp-bulk-sender/whatsapp-bulk-sender/backend/requirements.txt /app/whatsapp-bulk-sender/whatsapp-bulk-sender/backend/
COPY whatsapp-bulk-sender/wa-server/package.json /app/whatsapp-bulk-sender/wa-server/

# Install Python dependencies
RUN pip install --no-cache-dir -r fb-auto-poster/requirements.txt && \
    pip install --no-cache-dir -r fb-commenter-v2/requirements.txt && \
    pip install --no-cache-dir -r fb_buyers_egypt/requirements.txt && \
    pip install --no-cache-dir -r rekomnd_plus/requirements.txt && \
    pip install --no-cache-dir -r whatsapp-bulk-sender/whatsapp-bulk-sender/backend/requirements.txt

# Install Node dependencies
RUN cd /app/whatsapp-bulk-sender/wa-server && npm install

# Copy the rest of the application
COPY . /app

# Configure Nginx and startup script
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Entrypoint
CMD ["/start.sh"]
