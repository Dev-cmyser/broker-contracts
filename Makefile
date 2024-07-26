SRC_DIR := ./src
SRC_LANG := .ts
OUT_DIR := models
CONFIGS_DIR := configs

FILES := $(wildcard $(SRC_DIR)/*$(SRC_LANG))

TS_TARGETS := $(patsubst $(SRC_DIR)/%$(SRC_LANG),$(OUT_DIR)/ts/%.ts,$(FILES))
PHP_TARGETS := $(patsubst $(SRC_DIR)/%$(SRC_LANG),$(OUT_DIR)/php/%.php,$(FILES))

typescript: $(TS_TARGETS)

php:  $(PHP_TARGETS)

generate_configs:
	$(shell pwd)/scripts/generate_configs.sh
	npm run format -- 'configs'

# rules for gen .ts files
$(OUT_DIR)/ts/%.ts: $(SRC_DIR)/%$(SRC_LANG)
	npm run generate --  $< --lang typescript --just-types --src-lang typescript -o $@
	npm run format -- $@

# rules for gen .php files
$(OUT_DIR)/php/%.php: $(SRC_DIR)/%$(SRC_LANG)
	npm run generate -- $< --lang php --with-get --with-set --src-lang schema -o $@
	./scripts/split_php_classes.sh $@
	npm run format -- $@


all: clean typescript php generate_configs

clean:
	rm -rf $(OUT_DIR)/ts/*
	rm -rf $(OUT_DIR)/php/*
	rm -rf $(CONFIGS_DIR)
