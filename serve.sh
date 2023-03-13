#!/bin/bash
export SSL_CERT_FILE=./cacert.pem
bundle exec jekyll serve --force-polling
