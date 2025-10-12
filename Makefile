SHELL := /bin/bash
NVIM  ?= nvim
INIT  ?= scripts/minimal_init.lua

TEST_CMD = $(NVIM) --headless -u $(INIT) -c "lua MiniTest.run()"

.PHONY: test test-watch

test:
	@echo "🧪 Running tests at $$(date '+%Y-%m-%d %H:%M:%S')"
	@$(TEST_CMD)
	@echo "✅ Finished at $$(date '+%Y-%m-%d %H:%M:%S')"

test-watch:
	@echo "👀 Polling spec/**/*.lua and lua/**/*.lua every 1s … (Ctrl-C to stop)"; \
	last=""; \
	while true; do \
	  cur="$$(find spec lua -type f -name '*.lua' -print0 | xargs -0 stat -f '%m %N' 2>/dev/null)"; \
	  if [ "$$cur" != "$$last" ]; then \
	    clear; \
	    echo "───────────────────────────────────────────────"; \
	    echo "🕒 $$(date '+%Y-%m-%d %H:%M:%S') — change detected, running tests…"; \
	    echo "───────────────────────────────────────────────"; \
	    start_time=$$(date +%s); \
	    $(TEST_CMD) && result="✅ Completed" || result="❌ Failed"; \
	    end_time=$$(date +%s); \
	    duration=$$((end_time - start_time)); \
	    echo "$$result at $$(date '+%H:%M:%S') (took $$duration sec)"; \
	    echo; \
	    last="$$cur"; \
	  fi; \
	  sleep 1; \
	done
