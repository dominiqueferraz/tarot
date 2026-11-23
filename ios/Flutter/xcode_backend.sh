#!/bin/sh
set -eu

if [ "$1" = prepare ]; then
    unset SWIFT_DEBUG_INFORMATION_FORMAT SWIFT_DEBUG_INFORMATION_VERSION
fi
exec "$SRCROOT/../bin/flutter" xcode-backend "$@"
