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
	$(MAKE) -C buildroot $(BUILDROOT_ARGS)

buildroot-menuconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) menuconfig

buildroot-savedefconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) savedefconfig

clean:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) clean
