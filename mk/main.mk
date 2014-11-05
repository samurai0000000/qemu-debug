# main.mk

CROSS_COMPILE ?=	arm-none-linux-gnueabi-

.PHONY: qemu

qemu: out/host/linux-x86/bin/acp
	mkdir -p out/host/linux-x86/obj/STATIC_LIBRARIES/libSDL_intermediates
	touch out/host/linux-x86/obj/STATIC_LIBRARIES/libSDL_intermediates/export_includes
	mkdir -p out/host/linux-x86/obj/STATIC_LIBRARIES/libSDLmain_intermediates
	touch out/host/linux-x86/obj/STATIC_LIBRARIES/libSDLmain_intermediates/export_includes
	mkdir -p out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDL_intermediates
	touch out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDL_intermediates/export_includes
	mkdir -p out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDLmain_intermediates
	touch out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDLmain_intermediates/export_includes
	cp prebuilts/tools/linux-x86/sdl/libs/libSDL.a out/host/linux-x86/obj/STATIC_LIBRARIES/libSDL_intermediates/
	cp prebuilts/tools/linux-x86/sdl/libs/libSDLmain.a out/host/linux-x86/obj/STATIC_LIBRARIES/libSDLmain_intermediates/
	cp prebuilts/tools/linux-x86/sdl/libs/lib64SDL.a out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDL_intermediates/
	cp prebuilts/tools/linux-x86/sdl/libs/lib64SDLmain.a out/host/linux-x86/obj/STATIC_LIBRARIES/lib64SDLmain_intermediates/
	cd external/qemu && ONE_SHOT_MAKEFILE=external/qemu/Android.mk $(MAKE) -C $(TOP) -f build/core/main.mk all_modules

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

run-qemu: kernel/goldfish/arch/arm/boot/zImage
	out/host/linux-x86/bin/emulator --to-be-fixed kernel/goldfish/arch/arm/boot/zImage

.PHONY: clean

clean:
	rm -rf out

out/host/linux-x86/bin/acp: qemu-debug/bin/acp
	mkdir -p out/host/linux-x86/bin && cp $< $@
