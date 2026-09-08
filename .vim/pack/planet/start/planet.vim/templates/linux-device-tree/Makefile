all: example.dtb
example.dtb: example.dts
	dtc -I dts -O dtb -o $@ $<
clean:
	rm -f example.dtb
