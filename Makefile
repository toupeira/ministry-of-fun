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
	@simple-http-server -i --open --nocache --coop --coep build/web

publish: web
	@butler push build/web "${user}/${game}:web"

status:
	@butler status "${user}/${game}:web"
