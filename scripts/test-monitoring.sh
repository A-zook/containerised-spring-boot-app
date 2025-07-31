#!/bin/bash

echo "🔍 Testing monitoring setup..."

echo "1. Testing EC2 app metrics endpoint..."
curl -s http://13.222.39.38:8484/actuator/prometheus | head -10

echo ""
echo "2. Checking Prometheus targets (run this in browser):"
echo "   http://localhost:9090/targets"

echo ""
echo "3. Testing Prometheus query (run this in browser):"
echo "   http://localhost:9090/graph?g0.expr=http_server_requests_seconds_count"

echo ""
echo "4. Grafana data source test:"
echo "   - Go to http://localhost:3000"
echo "   - Configuration > Data Sources > Prometheus"
echo "   - Click 'Test' button"

echo ""
echo "5. Quick Grafana queries to try:"
echo "   - sum(http_server_requests_seconds_count)"
echo "   - jvm_memory_used_bytes"
echo "   - process_cpu_usage"

echo ""
echo "📊 If Prometheus shows your EC2 target as UP, but Grafana shows no data:"
echo "   - Check data source URL in Grafana"
echo "   - Try queries in Grafana Explore first"
echo "   - Verify time range (last 1 hour)"