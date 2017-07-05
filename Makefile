SOURCES := $(wildcard source/*.v)

default: sim

mystorm: chip.bin

chip.bin: chip.txt
	icepack chip.txt chip.bin

chip.txt: chip.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt

chip.blif: $(SOURCES)
	yosys -q -p "read_verilog -sv source/top.v; synth_ice40 -blif chip.blif"

.PHONY: upload clean sim default mystorm

upload:
	cat chip.bin >/dev/ttyUSB0

clean:
	$(RM) -f chip.{blif,txt,ex,bin}

sim:
	cd source && iverilog -g2005-sv -o simulate testbench.v && vvp simulate
