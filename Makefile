PROJECT     := Source/Saml2.Authentication/Saml2.Authentication.csproj
CONFIG      := Release
OUTPUT_DIR  := Source/Saml2.Authentication/bin/$(CONFIG)
NUGET_SOURCE := https://api.nuget.org/v3/index.json

.PHONY: help restore build package package-deliver clean

.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  help             Show this list (default)"
	@echo "  restore          Restore NuGet dependencies"
	@echo "  build            Build the project ($(CONFIG))"
	@echo "  package          Produce .nupkg/.snupkg in $(OUTPUT_DIR)"
	@echo "  package-deliver  Build, prompt for NuGet API key, push to $(NUGET_SOURCE)"
	@echo "  clean            Remove build outputs and packages"

restore:
	dotnet restore $(PROJECT)

build: restore
	dotnet build $(PROJECT) -c $(CONFIG) --no-restore

package: build
	dotnet pack $(PROJECT) -c $(CONFIG) --no-build -o $(OUTPUT_DIR)
	@echo "Packages produced in $(OUTPUT_DIR):"
	@ls $(OUTPUT_DIR)/*.nupkg

package-deliver: package
	@read -p "NuGet API key: " -s NUGET_API_KEY; echo; \
	if [ -z "$$NUGET_API_KEY" ]; then \
		echo "Error: API key is required"; exit 1; \
	fi; \
	for pkg in $(OUTPUT_DIR)/*.nupkg; do \
		echo "Pushing $$pkg"; \
		dotnet nuget push "$$pkg" --api-key "$$NUGET_API_KEY" --source $(NUGET_SOURCE) --skip-duplicate || exit 1; \
	done

clean:
	dotnet clean $(PROJECT) -c $(CONFIG)
	rm -rf $(OUTPUT_DIR)/*.nupkg $(OUTPUT_DIR)/*.snupkg
