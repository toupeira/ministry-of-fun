clean:
	@rm -rv build

import:
	@godot --headless --import

web:
	@rm -rf build/web
	@mkdir -p build/web
	@godot --headless --export-release Web
	@cd build/web && zip -r build.zip .
