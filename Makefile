##
# Nothing beats the original Makefile for simplicity
##

# This is list of typical commands needed in development
install:
	bundle install
	npm install --verbose

	cp -r node_modules/font-awesome/fonts/* fonts/
	cp -r node_modules/open-sans-fontface/fonts fonts/open-sans

	# Build webpack
	./node_modules/webpack/bin/webpack.js

# This is for deveplopment so that we can see the created changes ASAP
serve: install
	JEKYLL_ENV=development bundle exec jekyll serve --config _config.yml,_config/development.yml

# This creates production build which minifies everything
build: install
	# This sets correct modified date into all posts
	bundle exec bin/add-modified-date-to-posts.rb
	JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config/production.yml

# Tests created documents
test:
	bundle exec htmlproofer ./_site --check-opengraph --check-favicon
