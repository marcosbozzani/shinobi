define headsup_c
	$(info,headsup -c $(1) $(2))
	headsup -c $(1) $(2)
endef

define headsup_h
	$(info,headsup -h $(1) $(2))
	headsup -h $(1) $(2)
endef

define compile
	$(info,gcc -c $(2) -o $(1) $(cflags) -MMD -MT $(1) -MF $(1).d)
	gcc -c $(2) -o $(1) $(cflags) -MMD -MT $(1) -MF $(1).d
endef

define link
	$(info,gcc $(2) -o $(1) $(cflags))
	gcc $(2) -o $(1) $(cflags)
endef

ifeq ($(OS),Windows_NT)
define mkdirp
	cmd /c if not exist $(subst /,\\,$(1)) ( md $(subst /,\\,$(1)) )
endef
else
define mkdirp
	mkdir -p $(1)
endef
endif