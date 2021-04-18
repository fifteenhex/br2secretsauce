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

# For CI caching. Download all of the source so you
# can cache it and reuse it for then next build
buildroot-dl: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) source

buildroot-menuconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) menuconfig

buildroot-savedefconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) savedefconfig

# Save a toolchain so that other people don't need to build
# it..

buildroot-toolchain:
	$(MAKE) -C buildroot sdk

clean:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) clean
