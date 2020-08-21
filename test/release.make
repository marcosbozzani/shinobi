cflags = -Isource -Irelease/declaration -O3 -s -fvisibility=hidden -fdiagnostics-color=always -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers

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

.PHONY: all
all: directories release/app.exe

release/app.exe: \
  release/object/calc.o \
  release/object/main.o
	$(call link,$@,$^)

.PHONY: directories
directories: release release/declaration release/object

release: 
	$(call mkdirp,$@,$^)

release/declaration: 
	$(call mkdirp,$@,$^)

release/object: 
	$(call mkdirp,$@,$^)

.PHONY: declarations
declarations: \
  release/declaration/calc.c.decl \
  release/declaration/calc.h.decl \
  release/declaration/main.c.decl

release/object/calc.o: source/calc.c | declarations
	$(call compile,$@,$^)

release/declaration/calc.c.decl: source/calc.c source/calc.h
	$(call headsup_c,$@,$^)

release/declaration/calc.h.decl: source/calc.c source/calc.h
	$(call headsup_h,$@,$^)

release/object/main.o: source/main.c | declarations
	$(call compile,$@,$^)

release/declaration/main.c.decl: source/main.c
	$(call headsup_c,$@,$^)

-include release/object/calc.d
-include release/object/main.d

.DEFAULT_GOAL: all
