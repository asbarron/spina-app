#!/bin/bash

cd spina-app || { echo "Directory not found"; exit 1; }

if [ -e ".env" ]; then
    docker-compose down
    docker-compose build > /dev/null || { echo "Build failed"; exit 1; }
    docker-compose up -d > /dev/null || { echo "Error starting containers"; exit 1; }
    echo "Docker containers started successfully"
else
    echo "Missing .env file. Please create one and try again. See README.md for more info"
    exit 1
fi



