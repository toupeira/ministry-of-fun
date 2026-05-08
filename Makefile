game = ministry-of-fun
user = toupeira

clean:
	@rm -rv build/*

import:
	@godot --headless --import

reuse:
	@reuse download --all
	@reuse lint

linux:
	@mkdir -p build/linux
	@godot --headless --export-release Linux

web:
	@mkdir -p build/web
	@godot --headless --export-release Web

browser: web
	@xdg-open "http://localhost:8000/" &>/dev/null
	@cd build/web && python3 -m http.server

publish: web
	@butler push build/web "${user}/${game}:web"

status:
	@butler status "${user}/${game}:web"
