FORMATTER=mvdan.cc/gofumpt@latest
LINTER=github.com/golangci/golangci-lint/cmd/golangci-lint@latest

.PHONY: default
default: vet fix fmt lint test

.PHONY: vet
vet:
	@echo "go vet"
	@go vet ./...

.PHONY: fix
fix:
	@echo "go fix"
	@go fix ./...

.PHONY: fmt
fmt:
	@echo "go fmt"
	@go run $(FORMATTER) -l -w .

.PHONY: lint
lint:
	@echo "go lint"
	@go run $(LINTER) run

.PHONY: test
test:
	@echo "go test"
	@go test ./...

.PHONY: air
air:
	@echo "go air"
	@go run $(AIR)

.PHONY: run
run:
	@echo "go run (without live reloading)"
	@go run github.com/tksasha/balance/cmd/balance

.PHONY: build
build:
	@echo "go build"
	@go build -o $(OUTPUT) $(MAIN)

.PHONY: clear
clear:
	@echo "go clear"
	@rm $(OUTPUT)

.PHONY: clean
clean: clear

.PHONY: gen
gen: wire mockgen

.PHONY: mockgen
mockgen:
	@go run $(MOCKGEN) \
		-source internal/core/cash/interfaces.go \
		-package mocks \
		-destination internal/core/cash/test/mocks/interfaces.mock.go
	@go run $(MOCKGEN) \
		-source internal/core/category/interfaces.go \
		-package mocks \
		-destination internal/core/category/test/mocks/interfaces.mock.go
	@go run $(MOCKGEN) \
		-source internal/core/item/interfaces.go \
		-package mocks \
		-destination internal/core/item/test/mocks/interfaces.mock.go
	@go run $(MOCKGEN) \
		-source internal/core/index/interfaces.go \
		-package mocks \
		-destination internal/core/index/test/mocks/interfaces.mock.go

.PHONY: wire
wire:
	@echo "wire gen"
	@go run $(WIRE) internal/wire/wire.go

.PHONY: migration
migration:
	@if [ -z "$(name)" ]; then echo "name is required"; exit 1; fi
	touch "internal/db/migrations/$(shell date "+%Y%m%d%H%M%S")_$(name).sql"
