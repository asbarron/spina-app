#!/bin/bash

# Func to log messages to term and file
log() {
  local message="$1"
  echo "$message" | tee -a "$LOGFILE"
}

# Set default log file name
LOGFILE="run.log"

# Helper func to load .env files
load_env_file() {
  local env_file="$1"
  BUILD_ARGS=""
  
  if [ -f "$env_file" ]; then
    # Use a while loop with file descriptor to ensure proper handling of the last line
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip lines that are empty or start with a comment
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        # Escape single quotes in values
        value=$(printf '%s\n' "$value" | sed "s/'/'\\\\''/g")
        # Append build arg string
        BUILD_ARGS+="--build-arg $key=$value "
    done < "$env_file"
    
    log "Loaded environment variables from $env_file"
    log "Build args: $BUILD_ARGS"
  else
    log "Error: $env_file not found."
    exit 1
  fi
}

# Main run script logic
main() {
  # Check for env arg
  if [ -z "$ENV" ]; then
    log "Usage: ./run.sh [dev|prod]"
    exit 1
  fi

  # Determine env
  case "$ENV" in
    prod)
      export RAILS_ENV="production"
      ENV_FILE=".env.prod"
      ;;
    dev)
      export RAILS_ENV="development"
      ENV_FILE=".env.dev"
      ;;
    *)
      log "Invalid environment: $ENV. Use 'dev' or 'prod'."
      exit 1
      ;;
  esac

  log "Environment set to $ENV. RAILS_ENV set to $RAILS_ENV"
  load_env_file "$ENV_FILE"
  
  # Removing old volumes
  log "Removing old volumes"
  docker-compose down -v >> "$LOGFILE" 2>&1 || {
    log "Error removing old volumes. Check $LOGFILE for details."
    exit 1
  }
  # Build Docker containers
  log "Building Docker containers"
  docker-compose build --no-cache $BUILD_ARGS >> "$LOGFILE" 2>&1 || {
    log "Build failed. Check $LOGFILE for details."
    exit 1
  }

  # Start Docker containers
  log "Starting Docker containers"
  docker-compose up -d >> "$LOGFILE" 2>&1 || {
    log "Error starting containers. Check $LOGFILE for details."
    exit 1
  }

  log "Docker containers started successfully"
}

# Set env from arg
ENV=$1

# Start main func
main