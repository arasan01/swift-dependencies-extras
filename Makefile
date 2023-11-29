# install swift-format from brew
setup:
	brew install swift-format

# format swift files
format:
	swift-format format -i --configuration swift-format.json -r Sources
	swift-format format -i --configuration swift-format.json -r Tests

docc-preview:
	swift package --disable-sandbox preview-documentation --target DependenciesExtrasMacros --port 12342

PHONY: setup format docc-preview
