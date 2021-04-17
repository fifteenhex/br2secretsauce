OUTPUTS=$(PWD)/outputs
DLDIR=$(PWD)/dl

BUILDROOT_ARGS += BR2_DL_DIR=$(DLDIR) BR2_EXTERNAL="$(EXTERNALS)"

.PHONY: buildroot

$(OUTPUTS):
	mkdir -p $(OUTPUTS)

$(DLDIR):
	mkdir -p $(DLDIR)

buildroot: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C buildroot $(BUILDROOT_ARGS)

buildroot-menuconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) menuconfig

buildroot-savedefconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) savedefconfig

clean:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) clean
