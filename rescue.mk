BUILDROOT_RESCUE_ARGS += BR2_DL_DIR=$(DLDIR) BR2_EXTERNAL="$(EXTERNALS)"

ifdef DEFCONFIG_RESCUE
	BUILDROOT_RESCUE_ARGS += BR2_DEFCONFIG="$(DEFCONFIG_RESCUE)"
endif

.PHONY: buildroot_rescue

buildroot-rescue: $(OUTPUTS) $(DLDIR)
# Buildroot generates so much output drone ci can
# handle it, so tell make to be quiet
	$(MAKE) -s -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS)

# For CI caching. Download all of the source so you
# can cache it and reuse it for then next build
buildroot-rescue-dl: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS) defconfig
	$(MAKE) -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS) source
	$(call update_git_package,linux,buildroot_rescue)

buildroot-rescue-menuconfig:
	$(MAKE) -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS) menuconfig

buildroot-rescue-savedefconfig:
	$(MAKE) -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS) savedefconfig

buildroot-rescue-linux-menuconfig:
	$(MAKE) -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS) linux-menuconfig

buildroot-rescue-clean:
	$(MAKE) -C buildroot_rescue $(BUILDROOT_RESCUE_ARGS) clean
