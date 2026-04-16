clean:
	@rm -rv build/*

import:
	@godot --headless --import

web: web-export web-serve

web-export:
	@rm -rf build/web
	@mkdir -p build/web
	@godot --headless --export-release Web

web-zip: web-export
	@cd build/web && zip -r lot49.zip .
	@echo
	@du -h build/web/lot49.zip
	@echo

web-serve: web-export
	@xdg-open "http://localhost:8000/" &>/dev/null
	@cd build/web && python3 -m http.server
