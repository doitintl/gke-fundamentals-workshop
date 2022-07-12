EXECUTABLES = pre-commit kubent yq
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

install-hooks:
	pre-commit install-hooks

pre-commit-run:
	pre-commit run -a

kubent:
	cat `find . -name *.yaml -not -path ./.pre-commit-config.yaml` | yq -y | kubent -f -
