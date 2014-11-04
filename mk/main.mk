.PHONY: qemu

qemu: out/host/linux-x86/bin/acp
	cd external/qemu && ONE_SHOT_MAKEFILE=external/qemu/Android.mk $(MAKE) -C $(TOP) -f build/core/main.mk all_modules

.PHONY: clean

clean:
	rm -rf out

out/host/linux-x86/bin/acp: qemu-debug/bin/acp
	mkdir -p out/host/linux-x86/bin && cp $< $@
