.PHONY: qemu

qemu: out/host/linux-x86/bin/acp

out/host/linux-x86/bin/acp: qemu-debug/bin/acp
	mkdir -p out/host/linux-x86/bin &&bin cp $< $@
