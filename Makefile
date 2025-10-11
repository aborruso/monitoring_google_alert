# Makefile for Google Alert Monitor

# Default command to run when no arguments are given
.DEFAULT_GOAL := help

# Variables
INSTALL_DIR ?= /usr/local/bin
SCRIPT_NAME = update_feed.sh
SCRIPT_SRC = script/$(SCRIPT_NAME)
# Use a more descriptive name for the installed command
CMD_NAME = google-alert-monitor
INSTALL_TARGET = $(INSTALL_DIR)/$(CMD_NAME)

.PHONY: install uninstall update test help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install    Install the script to $(INSTALL_DIR) as $(CMD_NAME)"
	@echo "  uninstall  Uninstall the script from $(INSTALL_DIR)"
	@echo "  update     Run the script to update the feed timeline from config.yml"
	@echo "  test       Run a test conversion of a single feed to stdout"
	@echo "  help       Show this help message"

install:
	@echo "Installing $(CMD_NAME) to $(INSTALL_TARGET)..."
	@if ! command -v yq > /dev/null; then \
		echo "Error: yq (https://github.com/kislyuk/yq) is not installed. Please install it via pip: 'pip install yq'"; \
		exit 1; \
	fi
	@if ! command -v mlr > /dev/null; then \
		echo "Error: miller (mlr) is not installed. Please install it using your system's package manager (e.g., 'sudo apt-get install miller')."; \
		exit 1; \
	fi
	@echo "Attempting to copy script. This may require sudo privileges."
	@sudo cp $(SCRIPT_SRC) $(INSTALL_TARGET)
	@sudo chmod +x $(INSTALL_TARGET)
	@echo "Installation complete. You can now use the '$(CMD_NAME)' command."

uninstall:
	@echo "Uninstalling $(CMD_NAME) from $(INSTALL_TARGET)..."
	@sudo rm -f $(INSTALL_TARGET)
	@echo "Uninstallation complete."

update:
	@bash $(SCRIPT_SRC)

test:
	@bash $(SCRIPT_SRC) --feed "https://www.google.com/alerts/feeds/15244278077982194024/16384461912871559641"
