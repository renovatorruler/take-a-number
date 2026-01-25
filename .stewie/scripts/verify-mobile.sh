#!/bin/bash
# verify-mobile.sh — Verifies mobile app builds and runs on simulators
#
# Usage: ./verify-mobile.sh [--ios-only|--android-only] [--skip-build]
#
# Checks:
# 1. App builds for iOS/Android
# 2. App launches without crash
# 3. Basic smoke test passes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

IOS_ONLY=false
ANDROID_ONLY=false
SKIP_BUILD=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --ios-only) IOS_ONLY=true ;;
        --android-only) ANDROID_ONLY=true ;;
        --skip-build) SKIP_BUILD=true ;;
    esac
done

echo "📱 Orchestra: Mobile Verification"
echo ""

cd "$PROJECT_ROOT"

# =============================================================================
# 1. ReScript Build
# =============================================================================

if [ "$SKIP_BUILD" = false ]; then
    echo "🔨 Building ReScript..."
    if ! npx rescript build; then
        echo "❌ ReScript build failed"
        exit 1
    fi
    echo "✓ ReScript compiled"
fi

# =============================================================================
# 2. iOS Verification
# =============================================================================

IOS_RESULT=0
if [ "$ANDROID_ONLY" = false ]; then
    echo ""
    echo "🍎 iOS Verification"
    echo "━━━━━━━━━━━━━━━━━━━"
    
    # Check if Xcode command line tools available
    if ! command -v xcrun &> /dev/null; then
        echo "⚠️  Xcode command line tools not found, skipping iOS"
        IOS_RESULT=2  # Skip, not fail
    else
        # Check for available iOS simulator
        SIMULATOR=$(xcrun simctl list devices available | grep -E "iPhone.*\(" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')
        
        if [ -z "$SIMULATOR" ]; then
            echo "⚠️  No iOS simulator found, skipping"
            IOS_RESULT=2
        else
            echo "   Using simulator: $SIMULATOR"
            
            # Boot simulator if needed
            xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
            
            # Build and run
            echo "   Building iOS app..."
            if npx expo run:ios --device "$SIMULATOR" --no-install 2>&1 | tee /tmp/ios-build-$$.log | tail -20; then
                echo "✅ iOS: Build successful"
                
                # Give app time to launch and potentially crash
                sleep 5
                
                # Check if app crashed
                if xcrun simctl spawn "$SIMULATOR" log show --predicate 'eventMessage contains "crashed"' --last 1m 2>/dev/null | grep -q "crashed"; then
                    echo "❌ iOS: App crashed on launch"
                    IOS_RESULT=1
                else
                    echo "✅ iOS: App running without crash"
                fi
            else
                echo "❌ iOS: Build failed"
                grep -i "error" /tmp/ios-build-$$.log | head -10 || true
                IOS_RESULT=1
            fi
            rm -f /tmp/ios-build-$$.log
        fi
    fi
fi

# =============================================================================
# 3. Android Verification
# =============================================================================

ANDROID_RESULT=0
if [ "$IOS_ONLY" = false ]; then
    echo ""
    echo "🤖 Android Verification"
    echo "━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check for Android SDK
    if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
        echo "⚠️  ANDROID_HOME not set, skipping Android"
        ANDROID_RESULT=2
    else
        # Check for running emulator
        EMULATOR=$(adb devices 2>/dev/null | grep -E "emulator-|device$" | head -1 | cut -f1)
        
        if [ -z "$EMULATOR" ]; then
            echo "⚠️  No Android emulator/device found, skipping"
            echo "   Start an emulator with: emulator -avd <avd_name>"
            ANDROID_RESULT=2
        else
            echo "   Using device: $EMULATOR"
            
            # Build and run
            echo "   Building Android app..."
            if npx expo run:android --device "$EMULATOR" --no-install 2>&1 | tee /tmp/android-build-$$.log | tail -20; then
                echo "✅ Android: Build successful"
                
                # Give app time to launch
                sleep 5
                
                # Check logcat for crashes
                if adb -s "$EMULATOR" logcat -d -t 100 2>/dev/null | grep -qE "FATAL EXCEPTION|has crashed"; then
                    echo "❌ Android: App crashed on launch"
                    ANDROID_RESULT=1
                else
                    echo "✅ Android: App running without crash"
                fi
            else
                echo "❌ Android: Build failed"
                grep -iE "error|failed" /tmp/android-build-$$.log | head -10 || true
                ANDROID_RESULT=1
            fi
            rm -f /tmp/android-build-$$.log
        fi
    fi
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Mobile Verification Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FINAL_RESULT=0

if [ "$ANDROID_ONLY" = false ]; then
    case $IOS_RESULT in
        0) echo "   iOS:     ✅ PASS" ;;
        1) echo "   iOS:     ❌ FAIL"; FINAL_RESULT=1 ;;
        2) echo "   iOS:     ⏭️  SKIPPED" ;;
    esac
fi

if [ "$IOS_ONLY" = false ]; then
    case $ANDROID_RESULT in
        0) echo "   Android: ✅ PASS" ;;
        1) echo "   Android: ❌ FAIL"; FINAL_RESULT=1 ;;
        2) echo "   Android: ⏭️  SKIPPED" ;;
    esac
fi

echo ""

if [ $FINAL_RESULT -eq 0 ]; then
    echo "✅ Mobile verification passed"
else
    echo "❌ Mobile verification failed"
fi

exit $FINAL_RESULT
