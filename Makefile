.PHONY: run_test
run_test:
	./scripts/run-mptcp-test.sh

.PHONY: clean
clean:
	rm -rf ./results/*.*
