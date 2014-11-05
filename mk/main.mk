.PHONY: qemu

qemu: out/host/linux-x86/bin/acp
	cd external/qemu && ONE_SHOT_MAKEFILE=external/qemu/Android.mk $(MAKE) -C $(TOP) -f build/core/main.mk all_modules

.PHONY: kernel

kernel: kernel/goldfish/arch/arm/boot/zImage

kernel/goldfish/arch/arm/boot/zImage: kernel/goldfish/.config
	CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm $(MAKE) -C kernel/goldfish

kernel/goldfish/.config: kernel/goldfish/arch/arm/configs/goldfish_armv7_defconfig
	CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm $(MAKE) -C kernel/goldfish goldfish_armv7_defconfig
	CROSS_COMPILE=arm-none-linux-gnueabi- ARCH=arm $(MAKE) -C kernel/goldfish oldconfig

.PHONY: clean_kernel

clean_kernel:
	$(MAKE) -C kernel/goldfish mrproper

.PHONY: run-qemu

run-qemu: kernel/goldfish/arch/arm/zImage
	out/host/linux-x86/bin/emulator --to-be-fixed kernel/goldfish/arch/arm/boot/zImage

.PHONY: clean

clean:
	rm -rf out

out/host/linux-x86/bin/acp: qemu-debug/bin/acp
	mkdir -p out/host/linux-x86/bin && cp $< $@
