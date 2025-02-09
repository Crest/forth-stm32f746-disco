FLASH_SOURCES=memmap.fs \
	bitfields.fs \
	common.fs \
	sysclk.fs \
	systick.fs \
	gpio.fs \
	colormap.fs \
	colors.fs \
	graphics-rk043fn48h.fs \
	graphics-text.fs \
	graphics-geometry.fs \
	graphics.fs \
	mco.fs

RAM_SOURCES=log.fs \
	status.fs \
	i2c.fs \
	sentral.fs \
	init-ram.fs

RCAS=./rcas
FLASH_UPLOAD_DELAY=15
RAM_UPLOAD_DELAY=5

upload-ram.fs: $(RAM_SOURCES) upload-flash.fs
	./reset
	cat $(RAM_SOURCES) | $(RCAS) > upload.fs
	./upload
	sleep $(RAM_UPLOAD_DELAY)
	mv upload.fs upload-ram.fs

upload-flash.fs: $(FLASH_SOURCES)
	./eraseflash
	printf "compiletoflash\n" > upload.fs
	cat $(FLASH_SOURCES) | $(RCAS) >> upload.fs
	printf "compiletoram\n" >> upload.fs
	./upload
	sleep $(FLASH_UPLOAD_DELAY)
	./reset
	mv upload.fs upload-flash.fs

ram:
	touch init-ram.fs
	make upload-ram.fs

memmap.fs bitfields.fs: registers.txt gen-cmsis STM32F7x6.svd
	./gen-cmsis

colormap.fs: x11-256-colors.json gen-colors
	./gen-colors

clean:
	-rm -f bitfields.fs memmap.fs colormap.fs upload.fs upload-*.fs

rom-swdcom:
	st-flash erase
	st-flash write rom/mecrisp-stellaris-stm32f746-swdcom.bin 0x08000000

rom:
	st-flash erase
	st-flash write rom/mecrisp-stellaris-stm32f746.bin 0x08000000

.PHONY: default clean flash rom rom-swd
