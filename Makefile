.PHONY: run_test
run_test:
	./scripts/run-mptcp-test.sh

.PHONY: reset
reset:
	./scripts/reset-network-settings.sh

.PHONY: clean
clean:
	rm -rf ./results/*.*
