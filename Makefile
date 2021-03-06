DATE=$(shell date +%I:%M%p)
HR=\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#

#
# BUILD DOCS
#

build:
	@echo "\n${HR}"
	@echo "Building Startup CakePHP..."
	@echo "${HR}\n"
	@echo "Install Composer..."
	@curl -sS https://getcomposer.org/installer | php
	@echo "Install Composer Packages..."
	@php composer.phar install
	@php -d "apc.enable_cli=1" ./Vendor/bin/cake.php --app ${PWD} bake project ${PWD} --empty --skel=./Console/Templates/skel
	@chmod -R 0777 ./tmp
	@php -d "apc.enable_cli=1" ./Vendor/bin/cake.php --app ${PWD} bake db_config
	@echo "Install Bower Components..."
	@bower install
	@echo "\n${HR}"
	@echo "Startup CakePHP successfully built at ${DATE}."
	@echo "${HR}\n"

update:
	@echo "Update Composer Packages..."
	@php composer.phar self-update
	@php composer.phar update
	@echo "Update Bower Components..."
	@bower update

clean:
	@cp -r ./Console/Templates/skel ./skel
	@rm -rf ./Config ./Console ./Controller ./Lib ./Locale ./Model ./Plugin ./Test ./tmp ./Vendor ./View ./webroot ./composer.lock ./composer.phar
	@mkdir -p ./Console/Templates
	@mv ./skel ./Console/Templates/