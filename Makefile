.PHONY: build
build:
	cd cmd/proxy && buffalo build
	cd cmd/olympus && buffalo build

.PHONY: run
run: build
	./athens

.PHONY: docs
docs:
	cd docs && hugo

.PHONY: setup-dev-env
setup-dev-env:
	./scripts/get_dev_tools.sh
	$(MAKE) dev

.PHONY: verify
verify:
	./scripts/check_gofmt.sh
	./scripts/check_golint.sh
	./scripts/check_deps.sh

.PHONY: test
test:
	cd cmd/proxy && buffalo test
	cd cmd/olympus && buffalo test

.PHONY: test-unit
test-unit:
	./scripts/test_unit.sh

.PHONY: test-e2e
test-e2e:
	./scripts/test_e2e.sh

.PHONY: olympus-docker
olympus-docker:
	docker build -t gomods/olympus -f cmd/olympus/Dockerfile .

.PHONY: proxy-docker
proxy-docker:
	# TODO: this needs to change to gomods/proxy
	docker build -t gomods/athens -f cmd/proxy/Dockerfile .

bench:
	./scripts/benchmark.sh

.PHONY: alldeps
alldeps:
	docker-compose -p athensdev up -d mysql
	docker-compose -p athensdev up -d postgres
	docker-compose -p athensdev up -d mongo
	docker-compose -p athensdev up -d redis
	docker-compose -p athensdev up -d minio
	docker-compose -p athensdev up -d jaeger
	echo "sleeping for a bit to wait for the DB to come up"
	sleep 5	

.PHONY: dev
dev:
	docker-compose -p athensdev up -d mongo
	docker-compose -p athensdev up -d redis

.PHONY: down
down:
	docker-compose -p athensdev down
	docker volume prune

.PHONY: dev-teardown
dev-teardown:
	docker-compose -p athensdev down
	docker volume prune
