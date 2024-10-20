#!/bin/bash

CLOCK_FONT_PATH=$1

# TIME
fontbm \
    --font-file "${CLOCK_FONT_PATH}" \
    --output "../resources/fonts/time" \
    --chars 32 \
    --chars-file ./digits.txt \
    --font-size 86 \
    --color 255,255,255 \
    --background-color 0,0,0

# SECONDS
fontbm \
    --font-file "${CLOCK_FONT_PATH}" \
    --output "../resources/fonts/seconds" \
    --chars 32 \
    --chars-file ./digits.txt \
    --font-size 32 \
    --color 255,255,255 \
    --background-color 0,0,0

# SECONDS
fontbm \
    --font-file "${CLOCK_FONT_PATH}" \
    --output "../resources/fonts/date" \
    --chars 32 \
    --chars-file ./date.txt \
    --font-size 36 \
    --color 255,0,0 \
    --background-color 0,0,0

# FUEL
fontbm \
    --font-file "${CLOCK_FONT_PATH}" \
    --output "../resources/fonts/fuel" \
    --chars 32 \
    --chars-file ./fuel.txt \
    --font-size 24 \
    --color 255,255,255 \
    --background-color 0,0,0

