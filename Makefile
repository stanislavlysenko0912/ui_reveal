.PHONY: help get test format analyze
.DEFAULT_GOAL := help

# ----------------------------------------

FVM_CHECK := $(shell command -v fvm 2>/dev/null)

ifdef FVM_CHECK
    FLUTTER := fvm flutter
    DART := fvm dart
else
    FLUTTER := flutter
    DART := dart
endif

# ----------------------------------------

help:
	@echo "Available commands:"
	@echo "  make get        - flutter pub get"
	@echo "  make test       - run tests"
	@echo "  make format     - format code"
	@echo "  make analyze    - analyze project"

get:
	$(FLUTTER) pub get

test:
	$(FLUTTER) test

format:
	$(DART) format .

analyze:
	$(FLUTTER) analyze

hooks-install:
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit
	@echo "Git pre-commit hook installed."