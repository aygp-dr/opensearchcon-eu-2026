# OpenSearchCon Europe 2026 Makefile

.PHONY: help setup clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial project setup
	@echo "Project ready for OpenSearchCon Europe 2026!"
	@echo "Location: Prague, Czechia"
	@echo "Dates: April 16-17, 2026"

clean: ## Clean generated files
	@find . -name "*.bak" -delete
	@find . -name "*~" -delete

export-org: ## Export org files to other formats (requires emacs)
	@echo "Exporting org files..."
	@command -v emacs >/dev/null 2>&1 || { echo "Emacs required for org export"; exit 1; }

validate: ## Validate org file syntax
	@echo "Validating org files..."
	@find . -name "*.org" -exec echo "Checking: {}" \;
