FILES = spacelift.rb

all: build

build:
	rm -rf ./build/
	rm -rf ./lambda.zip
	mkdir ./build/
	cp -v $(FILES) ./build/
	cd ./build/ && zip -r ../lambda.zip . ../vendor/

clean:
	rm -rf ./build/

test:
	bundle exec ./test.rb

.PHONY: build
