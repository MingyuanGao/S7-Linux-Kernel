# Makefile for generating the boot.img for S7

build_job_number=$(shell grep processor /proc/cpuinfo|wc -l)

kernel=kernel/arch/arm64/boot/Image
ramdisk=images/initrd.img
dtb=images/exynos8890.dtb
board=SRPOI17A000KU
base=10000000
pagesize=2048
kernel_offset=00008000
ramdisk_offset=01000000

# ====================
boot.tar.md5: boot.tar
	(cat boot.tar; md5sum -t boot.tar) > $@

boot.tar: boot.img
	tar -Hustar -c boot.img > $@

boot.img: $(kernel) $(ramdisk) $(dtb) 
	mkbootimg --kernel $(kernel) --ramdisk $(ramdisk) --dt $(dtb) \
	--board $(board) --base $(base) --pagesize $(pagesize) \
	--kernel_offset $(kernel_offset) --ramdisk_offset $(ramdisk_offset) \
	-o $@

# ==================
$(kernel): 
	cp images/mbfs-herolet-defconfig kernel/.config	
	make -C kernel ARCH=arm64 CROSS_COMPILE=aarch64- Image -j$(build_job_number)

# =====================
.PHONY: clean distclean
clean: 
	rm -rf boot.img boot.tar boot.tar.md5
	make -C kernel clean

distclean:
	rm -rf boot.img boot.tar boot.tar.md5
	make -C kernel distclean

