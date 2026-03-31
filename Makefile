clean:
	rm -r build

web:
	rm -rf build/web
	mkdir -p build/web
	godot --headless --export-release Web
	cd build/web && zip -r build.zip .
