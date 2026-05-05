#!/bin/bash

/opt/dependency-check/bin/dependency-check.sh \
  --project "devsecops-app" \
  --scan . \
  --format HTML \
  --out dependency-check-report \
  --failOnCVSS 7
