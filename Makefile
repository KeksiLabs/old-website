##
# Nothing beats the original Makefile for simplicity
##

# This is list of typical commands needed in development
install:
	bundle install
	npm install
start: install
	bundle exec jekyll serve
build: install
	bundle exec jekyll build
