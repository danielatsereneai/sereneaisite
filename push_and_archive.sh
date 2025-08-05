#!/bin/bash

# This script automates Git commit and push, and creates a local archive of the website.

# --- Configuration ---
# Define the path to your website project directory.
# This script assumes it's run from within the 'sereneaisite' directory.
WEBSITE_DIR="/Users/sereneai/Desktop/sereneaisite"

# Define the base directory for your website archives.
# This will create a folder like /Users/sereneai/Desktop/website_archives/
ARCHIVE_BASE_DIR="/Users/sereneai/Desktop/website_archives"

# --- Functions ---

# Function to display messages
log_message() {
    echo "--- $1 ---"
}

# Function to handle errors and exit
error_exit() {
    log_message "ERROR: $1"
    exit 1
}

# --- Script Start ---

log_message "Starting Git Push and Archive Process..."

# 1. Change to the website directory
cd "$WEBSITE_DIR" || error_exit "Failed to change directory to $WEBSITE_DIR"
log_message "Current directory: $(pwd)"

# 2. Ensure Git identity is set (good practice for automated scripts)
# These should already be set globally, but including them for robustness.
git config user.name > /dev/null || git config --global user.name "Your Name"
git config user.email > /dev/null || git config --global user.email "your.email@example.com"

# 3. Prompt for Commit Message
COMMIT_MESSAGE=""
if [ -z "$1" ]; then
    read -p "Enter Git commit message (e.g., 'Update content'): " COMMIT_MESSAGE
else
    COMMIT_MESSAGE="$1"
    log_message "Using provided commit message: '$COMMIT_MESSAGE'"
fi

if [ -z "$COMMIT_MESSAGE" ]; then
    error_exit "Commit message cannot be empty. Please provide one."
fi

# 4. Stage all changes
log_message "Staging all changes..."
git add . || error_exit "Git add failed."

# 5. Commit changes
log_message "Committing changes with message: '$COMMIT_MESSAGE'..."
git commit -m "$COMMIT_MESSAGE" || error_exit "Git commit failed. No changes to commit or other error."

# 6. Push to GitHub
log_message "Pushing changes to GitHub..."
git push origin main || error_exit "Git push failed. Ensure 'origin' remote is set and you have permissions."
log_message "Successfully pushed to GitHub!"

# 7. Create a timestamped archive
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
ARCHIVE_DIR="$ARCHIVE_BASE_DIR/sereneaisite_$TIMESTAMP"

log_message "Creating website archive in: $ARCHIVE_DIR"

# Create the base archive directory if it doesn't exist
mkdir -p "$ARCHIVE_BASE_DIR" || error_exit "Failed to create archive base directory: $ARCHIVE_BASE_DIR"

# Copy the entire website directory, excluding the .git folder
# Using rsync for efficiency and to exclude .git
rsync -a --exclude='.git/' "$WEBSITE_DIR/" "$ARCHIVE_DIR/" || error_exit "Failed to create archive copy."

log_message "Website archived successfully!"

log_message "Process completed."

# The terminal will remain open but return to the prompt after the script finishes.
# To truly close the terminal window, you would typically run this script from an external
# terminal application (like macOS Terminal.app) and then close that window manually.
# In VS Code's integrated terminal, it will simply finish execution.
