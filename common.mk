OUTPUTS=$(PWD)/outputs
DLDIR=$(PWD)/dl

.PHONY: buildroot

$(OUTPUTS):
	mkdir -p $(OUTPUTS)

$(DLDIR):
	mkdir -p $(DLDIR)

bootstrap:
	git submodule init
	git submodule update

buildroot: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C buildroot

buildroot-menuconfig:
	$(MAKE) -C buildroot menuconfig

clean:
	$(MAKE) -C $(BUILDROOT_PATH) clean
