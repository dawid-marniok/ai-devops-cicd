.DEFAULT_GOAL := help
SHELL := /bin/bash

-include .env
export

NS      ?= $(USER)
APP     ?= quotes-api
VERSION ?= v1

.PHONY: help
help: ## Lista dostępnych komend
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

.PHONY: app-local
app-local: ## Uruchom quotes-api lokalnie na :8000
	cd app && pip install -q -r requirements.txt && uvicorn main:app --reload --port 8000

.PHONY: test
test: ## Testy aplikacji
	cd app && pytest -q

.PHONY: lint
lint: ## Lint aplikacji, modułów Terraform i workflowów
	cd app && ruff check .
	terraform fmt -check -recursive infra/
	@if command -v actionlint >/dev/null 2>&1; then actionlint; else echo "actionlint: pomijam (brak w PATH)"; fi

.PHONY: tf-validate
tf-validate: ## terraform validate + tflint + checkov + trivy
	./scripts/waliduj.sh

.PHONY: deploy
deploy: ## Obraz → skan → canary (NS=twoj-namespace VERSION=v2)
	./scripts/deploy.sh $(NS) $(VERSION)

.PHONY: canary
canary: ## Wdróż nową wersję jako canary
	kubectl argo rollouts set image $(APP) $(APP)=$$ECR_REPO:$(VERSION) -n $(NS)
	kubectl argo rollouts get rollout $(APP) -n $(NS) --watch

.PHONY: promote
promote: ## Przepuść canary do kolejnego kroku
	kubectl argo rollouts promote $(APP) -n $(NS)

.PHONY: rollback
rollback: ## Wycofaj Rollout do poprzedniej wersji
	kubectl argo rollouts undo $(APP) -n $(NS)
	kubectl argo rollouts get rollout $(APP) -n $(NS) --watch

.PHONY: load
load: ## Wygeneruj ruch do HPA i analizy canary
	./scripts/obciaz.sh $(NS)
