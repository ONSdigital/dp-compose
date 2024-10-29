# Include common make targets
include ../common.mk

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here
	gpg -d ../../../../dis-authentication-stub/static/keys/public.key.asc > ../../../../dis-authentication-stub/static/keys/public.key
	gpg -d ../../../../dis-authentication-stub/static/keys/private.key.asc > ../../../../dis-authentication-stub/static/keys/private.key
	gpg -d ../../../../dis-authentication-stub/static/keys/jwt-keys.json.asc > ../../../../dis-authentication-stub/static/keys/jwt-keys.json

# Add any stack specific helper targets here
