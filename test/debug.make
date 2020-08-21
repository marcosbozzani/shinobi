cflags = -Isource -Idebug/declaration -O0 -g -fvisibility=hidden -fdiagnostics-color=always -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers 

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
all: directories debug/app.exe

debug/app.exe: \
  debug/object/calc.o \
  debug/object/main.o
	$(call link,$@,$^)

.PHONY: directories
directories: debug debug/declaration debug/object

debug: 
	$(call mkdirp,$@,$^)

debug/declaration: 
	$(call mkdirp,$@,$^)

debug/object: 
	$(call mkdirp,$@,$^)

.PHONY: declarations
declarations: \
  debug/declaration/calc.c.decl \
  debug/declaration/calc.h.decl \
  debug/declaration/main.c.decl

debug/object/calc.o: source/calc.c | declarations
	$(call compile,$@,$^)

debug/declaration/calc.c.decl: source/calc.c source/calc.h
	$(call headsup_c,$@,$^)

debug/declaration/calc.h.decl: source/calc.c source/calc.h
	$(call headsup_h,$@,$^)

debug/object/main.o: source/main.c | declarations
	$(call compile,$@,$^)

debug/declaration/main.c.decl: source/main.c
	$(call headsup_c,$@,$^)

-include debug/object/calc.d
-include debug/object/main.d

.DEFAULT_GOAL: all
