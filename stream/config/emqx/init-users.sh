#!/bin/sh

# Wait for EMQX to be ready
echo "Waiting for EMQX to be ready..."
until emqx ping > /dev/null 2>&1; do
    echo "EMQX is not ready yet, waiting..."
    sleep 5
done

echo "EMQX is ready, creating MQTT user..."

# Create MQTT user using EMQX CLI
# Using built-in database authentication
emqx ctl users add "${MQTT_USER}" "${MQTT_USER_PASS}" || echo "User ${MQTT_USER} already exists or creation failed"

echo "MQTT user setup complete!"
echo "Dashboard: http://localhost:18083"
echo "Dashboard User: ${EMQX_DASHBOARD_USER}"
echo "MQTT User: ${MQTT_USER}"
