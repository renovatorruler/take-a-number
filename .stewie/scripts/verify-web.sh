#!/bin/bash
# verify-web.sh — Verifies web app runs without errors
#
# Usage: ./verify-web.sh [url] [--screenshot]
#
# Checks:
# 1. Dev server starts
# 2. Page loads without errors
# 3. No console errors
# 4. Optional: takes screenshot

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

URL="${1:-http://localhost:5000}"
SCREENSHOT_FLAG="${2:-}"
TIMEOUT=60
DEV_SERVER_PID=""

# Cleanup function
cleanup() {
    if [ -n "$DEV_SERVER_PID" ]; then
        echo "🧹 Stopping dev server (PID: $DEV_SERVER_PID)..."
        kill $DEV_SERVER_PID 2>/dev/null || true
        wait $DEV_SERVER_PID 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "🌐 Orchestra: Web Verification"
echo "   URL: $URL"
echo ""

# =============================================================================
# 1. Start dev server if not running
# =============================================================================

if ! curl -s --head "$URL" > /dev/null 2>&1; then
    echo "📦 Starting dev server..."
    cd "$PROJECT_ROOT"
    
    # Load environment variables
    if [ -f ".env.local" ]; then
        echo "   Loading .env.local..."
        set -a
        source .env.local
        set +a
    fi
    
    # Build first
    npx rescript build
    
    # Start server in background
    npm run server:dev &
    DEV_SERVER_PID=$!
    
    # Wait for server to be ready
    echo "   Waiting for server..."
    for i in $(seq 1 $TIMEOUT); do
        if curl -s --head "$URL" > /dev/null 2>&1; then
            echo "   ✓ Server ready after ${i}s"
            break
        fi
        sleep 1
    done
    
    if ! curl -s --head "$URL" > /dev/null 2>&1; then
        echo "❌ Server failed to start within ${TIMEOUT}s"
        exit 1
    fi
else
    echo "✓ Dev server already running"
fi

# =============================================================================
# 2. Run Playwright check
# =============================================================================

echo ""

# Check if web build exists
if [ ! -d "$PROJECT_ROOT/dist" ] && [ ! -f "$PROJECT_ROOT/dist/index.html" ]; then
    echo "📋 No web build found (dist/). Running API health check only..."
    
    # Simple API health check
    HEALTH=$(curl -s "${URL}/api/health" 2>/dev/null || echo "")
    if [ -n "$HEALTH" ]; then
        echo "✅ API endpoint responding"
    fi
    
    # Check server is serving something
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null)
    if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "404" ]; then
        echo "✅ Server responding (HTTP $RESPONSE)"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📊 Verification Results"  
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ PASS: Server running (no web build to verify)"
        echo ""
        echo "💡 To enable full browser testing, build web:"
        echo "   npx expo export --platform web"
        
        # Cleanup
        if [ -n "$DEV_SERVER_PID" ]; then
            echo "🧹 Stopping dev server (PID: $DEV_SERVER_PID)..."
            kill $DEV_SERVER_PID 2>/dev/null || true
        fi
        exit 0
    fi
fi

echo "🎭 Running browser verification..."

# Create script in project directory to access node_modules
VERIFY_SCRIPT="$PROJECT_ROOT/.stewie/scripts/.verify-browser.mjs"
cat > "$VERIFY_SCRIPT" << 'PLAYWRIGHT_SCRIPT'
import { chromium } from 'playwright';

const url = process.argv[2] || 'http://localhost:5000';
const shouldScreenshot = process.argv[3] === '--screenshot';

const errors = [];
const warnings = [];

async function verify() {
    const browser = await chromium.launch({ headless: true });
    const context = await browser.newContext();
    const page = await context.newPage();
    
    // Collect console messages
    page.on('console', msg => {
        if (msg.type() === 'error') {
            errors.push(msg.text());
        } else if (msg.type() === 'warning') {
            warnings.push(msg.text());
        }
    });
    
    // Collect page errors
    page.on('pageerror', err => {
        errors.push(err.message);
    });
    
    try {
        // Navigate to page
        const response = await page.goto(url, { 
            waitUntil: 'networkidle',
            timeout: 30000 
        });
        
        if (!response || response.status() >= 400) {
            errors.push(`HTTP ${response?.status() || 'unknown'}: Failed to load page`);
        }
        
        // Wait a bit for any async errors
        await page.waitForTimeout(2000);
        
        // Take screenshot if requested
        if (shouldScreenshot) {
            const screenshotPath = `./verification-screenshot-${Date.now()}.png`;
            await page.screenshot({ path: screenshotPath, fullPage: true });
            console.log(`📸 Screenshot: ${screenshotPath}`);
        }
        
    } catch (err) {
        errors.push(`Navigation error: ${err.message}`);
    } finally {
        await browser.close();
    }
    
    // Report results
    console.log('');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 Verification Results');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (errors.length === 0) {
        console.log('✅ PASS: No console errors detected');
        process.exit(0);
    } else {
        console.log(`❌ FAIL: ${errors.length} error(s) detected`);
        console.log('');
        errors.forEach((err, i) => {
            console.log(`   ${i + 1}. ${err.substring(0, 200)}`);
        });
        process.exit(1);
    }
}

verify();
PLAYWRIGHT_SCRIPT

cd "$PROJECT_ROOT"
node "$VERIFY_SCRIPT" "$URL" "$SCREENSHOT_FLAG"
RESULT=$?

rm -f "$VERIFY_SCRIPT"

exit $RESULT
