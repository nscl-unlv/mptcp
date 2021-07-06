.PHONY: run
run:
	./scripts/run-mptcp-test.sh $(FILE)

.PHONY: reset-mn
reset-mn:
	sudo mn -c

.PHONY: reset-network
reset-network:
	./scripts/reset-network-settings.sh

.PHONY: clean
clean:
	rm -rf ./results/*.*
