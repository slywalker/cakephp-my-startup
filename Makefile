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
	@./composer.phar install
	@./Vendor/bin/cake bake project ${PWD} --empty --skel=./Console/Templates/skel
	@./Vendor/bin/cake bake db_config
	@echo "Install Bower Components..."
	@bower install
	@echo "\n${HR}"
	@echo "Startup CakePHP successfully built at ${DATE}."
	@echo "${HR}\n"

clean:
	@cp -r ./Console/Templates/skel ./skel
	@rm -rf ./Config ./Console ./Controller ./Lib ./Locale ./Model ./Plugin ./Test ./tmp ./Vendor ./View ./webroot ./composer.lock ./composer.phar
	@mkdir -p ./Console/Templates
	@mv ./skel ./Console/Templates/