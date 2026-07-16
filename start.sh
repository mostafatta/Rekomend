#!/bin/bash
set -e

echo "Starting REKOMND+ Monorepo Container..."

# 1. Configure Nginx with dynamic Railway PORT
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf

# 2. Start backend services in background
echo "Starting FB Auto Poster (:5000)..."
export FLASK_PORT=5000
python fb-auto-poster/app.py &

echo "Starting FB Commenter (:5001)..."
export FLASK_PORT=5001
python fb-commenter-v2/app.py &

echo "Starting Buyers API (:8000)..."
uvicorn fb_buyers_egypt.api.server:app --host 127.0.0.1 --port 8000 --no-access-log &

echo "Starting WA Backend (:3001)..."
cd whatsapp-bulk-sender/whatsapp-bulk-sender/backend
uvicorn main:app --host 127.0.0.1 --port 3001 --no-access-log &
cd ../../../

echo "Starting WA Gateway (:8085)..."
cd whatsapp-bulk-sender/wa-server
PORT=8085 node server.js &
cd ../../

echo "Starting Main Dashboard (:7070)..."
export POSTER_URL="/proxy/poster"
export COMMENTER_URL="/proxy/commenter"
export BUYERS_URL="/proxy/buyers"
export WHATSAPP_URL="/proxy/wa-backend"
export WA_GATEWAY_URL="/proxy/wa-gateway"
cd rekomnd_plus
uvicorn main:app --host 127.0.0.1 --port 7070 --no-access-log &
cd ..

# 3. Start Nginx in foreground to keep container alive
echo "Starting Nginx Proxy on port $PORT..."
nginx -c /tmp/nginx.conf
