BUILD := build
RTL := $(wildcard rtl/*.sv)
DOCKER_RUN := docker run --rm -v $(CURDIR):/work \
	    --user $(shell id -u):$(shell id -g) \
	    -e CCACHE_DIR=/work/.ccache -e OBJCACHE=ccache \
	    riscv-ci-tools


.PHONY: sim lint clean regress docker-image docker-regress 

$(BUILD)/%/sim: tb/%.sv $(RTL)
	mkdir -p $(BUILD)/$*
	verilator --binary --timing -Wall -Wno-fatal -Mdir $(BUILD)/$* --top-module $* $< $(RTL) -o sim
sim: $(BUILD)/$(TEST)/sim
	./$(BUILD)/$(TEST)/sim

lint:
	verilator --lint-only -Wall -Wno-MULTITOP $(RTL)

clean:
	rm -rf $(BUILD) obj_dir
regress:
	python3 scripts/run_regression.py

docker-image:
	docker build -t riscv-ci-tools .

docker-regress:
	$(DOCKER_RUN) make regress
