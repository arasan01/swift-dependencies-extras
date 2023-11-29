# install swift-format from brew
setup:
	brew install swift-format

# format swift files
format:
	swift-format format -i --configuration swift-format.json -r Sources
	swift-format format -i --configuration swift-format.json -r Tests

PHONY: setup format
