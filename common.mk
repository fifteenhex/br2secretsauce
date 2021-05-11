OUTPUTS=$(PWD)/outputs
DLDIR=$(PWD)/dl

BUILDROOT_ARGS += BR2_DL_DIR=$(DLDIR) BR2_EXTERNAL="$(EXTERNALS)"

ifdef DEFCONFIG
	BUILDROOT_ARGS += BR2_DEFCONFIG="$(DEFCONFIG)"
endif

# Update a package that uses a git repo as it's
# upstream but the upstream rebases a known branch
# name
define update_git_package
	@echo updating git package $(1)
	git -C $(DLDIR)/$(1)/git clean -fd
	git -C $(DLDIR)/$(1)/git fetch --force --all --tags
	git -C $(DLDIR)/$(1)/git checkout master
	git -C $(DLDIR)/$(1)/ for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs -r git -C $(DLDIR)/$(1)/ branch -D
	git -C $(DLDIR)/$(1)/ branch
	rm -fv $(DLDIR)/$(1)/$(1)-*.tar.gz
	rm -rv buildroot/output/build/$(1)-*
endef

.PHONY: buildroot

$(OUTPUTS):
	mkdir -p $(OUTPUTS)

$(DLDIR):
	mkdir -p $(DLDIR)

buildroot: $(OUTPUTS) $(DLDIR)
# Buildroot generates so much output drone ci can
# handle it, so tell make to be quiet
	$(MAKE) -s -C buildroot $(BUILDROOT_ARGS)

# For CI caching. Download all of the source so you
# can cache it and reuse it for then next build
buildroot-dl: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) source
	$(call update_git_package,linux)
	$(call update_git_package,uboot)

buildroot-menuconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) menuconfig

buildroot-savedefconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) savedefconfig

# Save a toolchain so that other people don't need to build
# it..

buildroot-toolchain: $(OUTPUTS)
	$(MAKE) -C buildroot sdk
	cp buildroot/output/images/$(TOOLCHAIN) $(OUTPUTS)/$(PREFIX)-toolchain.tar.gz

buildroot-linux-menuconfig:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) linux-menuconfig

buildroot-clean:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) clean

clean: buildroot-clean
