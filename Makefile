BUILD := build
RTL := $(wildcard rtl/*.sv)

.PHONY: sim lint clean regress 

$(BUILD)/%/sim: tb/%.sv $(RTL)
	mkdir -p $(BUILD)/$*
	verilator --binary --timing -Wall -Wno-fatal -Mdir $(BUILD)/$* --top-module $* $< $(RTL) -o sim
sim: $(BUILD)/$(TEST)/sim
	./$(BUILD)/$(TEST)/sim

lint:
	verilator --lint-only -Wall $(RTL)

clean:
	rm -rf $(BUILD) obj_dir
regress:
	python3 scripts/run_regression.py
