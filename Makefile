SHELL                    := /usr/bin/env bash
TF_WORKSPACE             ?= default

.PHONY: install-git-pre-commit-hooks
# Install Git pre-commit hooks.
install-git-pre-commit-hooks:
	pre-commit install --overwrite

.PHONY: deploy
deploy:
	terraform apply -var spokeAK="$${spokeAK}" -var spokeSK="$${spokeSK}" -var public_key="$${SSH_PUB_KEY}"

.PHONY: destroy
destroy:
	terraform destroy -var spokeAK="$${spokeAK}" -var spokeSK="$${spokeSK}" -var public_key="$${SSH_PUB_KEY}"
