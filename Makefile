# OpenSearchCon Europe 2026 Makefile

.PHONY: help setup clean lint lint-fix new-talk tangle vale-sync

# Default target
.DEFAULT_GOAL := help

# Variables
VALE := vale
EMACS := emacs
TALKS_DIR := talks/proposals
TEMPLATE := talks/templates/talk-template.org

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: vale-sync ## Initial project setup
	@echo "Project ready for OpenSearchCon Europe 2026!"
	@echo "Location: Prague, Czechia"
	@echo "Dates: April 16-17, 2026"
	@echo ""
	@echo "Run 'gmake new-talk NAME=my-talk' to create a new proposal"

vale-sync: ## Download Vale packages
	@command -v $(VALE) >/dev/null 2>&1 || { echo "Vale not found. Install: brew install vale"; exit 1; }
	$(VALE) sync

lint: ## Lint all proposals with Vale
	@command -v $(VALE) >/dev/null 2>&1 || { echo "Vale not found. Install: brew install vale"; exit 1; }
	$(VALE) talks/ --glob='*.org' --glob='*.txt' --glob='*.md'

lint-proposals: ## Lint only submitted proposals
	@command -v $(VALE) >/dev/null 2>&1 || { echo "Vale not found. Install: brew install vale"; exit 1; }
	$(VALE) $(TALKS_DIR)/

lint-file: ## Lint a specific file (usage: gmake lint-file FILE=path/to/file)
	@command -v $(VALE) >/dev/null 2>&1 || { echo "Vale not found. Install: brew install vale"; exit 1; }
	$(VALE) $(FILE)

new-talk: ## Create new talk from template (usage: gmake new-talk NAME=my-talk)
ifndef NAME
	$(error NAME is required. Usage: gmake new-talk NAME=my-talk)
endif
	@mkdir -p $(TALKS_DIR)
	@if [ -f "$(TALKS_DIR)/$(NAME).org" ]; then \
		echo "Error: $(TALKS_DIR)/$(NAME).org already exists"; \
		exit 1; \
	fi
	@cp $(TEMPLATE) $(TALKS_DIR)/$(NAME).org
	@echo "Created $(TALKS_DIR)/$(NAME).org"
	@echo "Edit with: emacs $(TALKS_DIR)/$(NAME).org"

tangle: ## Tangle code from org files (extract source blocks)
	@command -v $(EMACS) >/dev/null 2>&1 || { echo "Emacs required for org-babel-tangle"; exit 1; }
	@for f in $(TALKS_DIR)/*.org; do \
		if [ -f "$$f" ]; then \
			echo "Tangling: $$f"; \
			$(EMACS) --batch -l org --eval "(org-babel-tangle-file \"$$f\")"; \
		fi \
	done

export-pdf: ## Export org files to PDF (requires LaTeX)
	@command -v $(EMACS) >/dev/null 2>&1 || { echo "Emacs required for export"; exit 1; }
	@command -v pdflatex >/dev/null 2>&1 || { echo "LaTeX required for PDF export"; exit 1; }
	@for f in $(TALKS_DIR)/*.org; do \
		if [ -f "$$f" ]; then \
			echo "Exporting: $$f"; \
			$(EMACS) --batch -l org --eval "(progn (find-file \"$$f\") (org-latex-export-to-pdf))"; \
		fi \
	done

export-html: ## Export org files to HTML
	@command -v $(EMACS) >/dev/null 2>&1 || { echo "Emacs required for export"; exit 1; }
	@for f in $(TALKS_DIR)/*.org; do \
		if [ -f "$$f" ]; then \
			echo "Exporting: $$f"; \
			$(EMACS) --batch -l org --eval "(progn (find-file \"$$f\") (org-html-export-to-html))"; \
		fi \
	done

clean: ## Clean generated files
	@find . -name "*.bak" -delete
	@find . -name "*~" -delete
	@find . -name "*.tex" -delete
	@find . -name "*.aux" -delete
	@find . -name "*.log" -delete
	@find . -name "*.toc" -delete
	@find . -name "*.out" -delete

validate: lint ## Alias for lint

word-count: ## Count words in abstracts
	@echo "Abstract word counts:"
	@for f in $(TALKS_DIR)/*/proposal/abstract.txt; do \
		if [ -f "$$f" ]; then \
			wc -w "$$f"; \
		fi \
	done 2>/dev/null || echo "No abstracts found yet"

check-deadline: ## Show days until CFP deadline
	@echo "CFP Deadline: January 18, 2026, 23:59 CET"
	@if command -v python3 >/dev/null 2>&1; then \
		python3 -c "from datetime import datetime; d=(datetime(2026,1,18)-datetime.now()).days; print(f'Days remaining: {d}')"; \
	fi
