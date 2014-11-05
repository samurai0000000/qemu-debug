# main.mk

CROSS_COMPILE ?=	arm-none-linux-gnueabi-

AVD ?=			qemu-debug

DEPOBJS = \
	out/host/linux-x86/bin/acp \
	out/host/linux-x86/obj/STATIC_LIBRARIES/libSDL_intermediates/export_includes \
	out/host/linux-x86/obj/STATIC_LIBRARIES/libSDLmain_intermediates/export_includes \
	out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDL_intermediates/export_includes \
	out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDLmain_intermediates/export_includes

.PHONY: qemu

qemu:  out/host/linux-x86/bin/emulator64-arm

out/host/linux-x86/bin/emulator64-arm: $(DEPOBJS)
	cd external/qemu && ONE_SHOT_MAKEFILE=external/qemu/Android.mk $(MAKE) -C $(TOP) -f build/core/main.mk all_modules $@

.PHONY: kernel

kernel: kernel/goldfish/arch/arm/boot/zImage

kernel/goldfish/arch/arm/boot/zImage: kernel/goldfish/.config
	CROSS_COMPILE=$(CROSS_COMPILE) ARCH=arm $(MAKE) -C kernel/goldfish

kernel/goldfish/.config: kernel/goldfish/arch/arm/configs/goldfish_armv7_defconfig
	CROSS_COMPILE=$(CROSS_COMPILE) ARCH=arm $(MAKE) -C kernel/goldfish goldfish_armv7_defconfig
	CROSS_COMPILE=$(CROSS_COMPILE) ARCH=arm $(MAKE) -C kernel/goldfish oldconfig

.PHONY: clean_kernel

clean_kernel:
	$(MAKE) -C kernel/goldfish mrproper

.PHONY: run-qemu

run-qemu: out/host/linux-x86/bin/emulator64-arm kernel/goldfish/arch/arm/boot/zImage
	out/host/linux-x86/bin/emulator64-arm -avd $(AVD) -gpu on -kernel kernel/goldfish/arch/arm/boot/zImage -system qemu-debug/img/system.img -ramdisk qemu-debug/img/ramdisk.img  -memory 1024 -partition-size 800 

.PHONY: clean

clean:
	rm -rf out

# DEPOBJS

out/host/linux-x86/bin/acp: qemu-debug/bin/acp
	mkdir -p out/host/linux-x86/bin && cp $< $@

out/host/linux-x86/obj/STATIC_LIBRARIES/libSDL_intermediates/export_includes:
	mkdir -p $(dir $@)
	touch $@
	cp prebuilts/tools/linux-x86/sdl/libs/libSDL.a $(dir $@)

out/host/linux-x86/obj/STATIC_LIBRARIES/libSDLmain_intermediates/export_includes:
	mkdir -p $(dir $@)
	touch $@
	cp prebuilts/tools/linux-x86/sdl/libs/libSDLmain.a $(dir $@)

out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDL_intermediates/export_includes:
	mkdir -p $(dir $@)
	touch $@
	cp prebuilts/tools/linux-x86/sdl/libs/lib64SDL.a $(dir $@)

out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDLmain_intermediates/export_includes:
	mkdir -p $(dir $@)
	touch $@
	cp prebuilts/tools/linux-x86/sdl/libs/lib64SDLmain.a $(dir $@)
