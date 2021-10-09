# workout the branch and if we need a prefix
# master is bare.
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
ifneq ($(BRANCH), master)
        BRANCH_PREFIX=$(BRANCH)-
endif

# output and dl directories
OUTPUTS=$(PWD)/outputs
DLDIR=$(PWD)/dl

BUILDROOT_ARGS += BR2_DL_DIR=$(DLDIR) BR2_EXTERNAL="$(EXTERNALS)"

ifndef DEFCONFIG
	$(error DEFCONFIG is not set)
endif

BUILDROOT_ARGS += BR2_DEFCONFIG="$(DEFCONFIG)"

# check the prefix is defined
ifndef PREFIX
endif

# check toolchain is defined
ifndef TOOLCHAIN
$(error TOOLCHAIN is not set)
endif

# Update a package that uses a git repo as it's
# upstream but the upstream rebases a known branch
# name
define update_git_package
	@echo updating git package $(1)
	if [ -d $(DLDIR)/$(1)/ ]; then \
		GITDIR=$(DLDIR)/$(1)/git; \
		git -C $$GITDIR clean -fd; \
		git -C $$GITDIR fetch --force --all --tags; \
		git -C $$GITDIR checkout master; \
		git -C $$GITDIR for-each-ref --format '%(refname:short)' refs/heads | \
			grep -v master | \
			xargs -r git -C $$GITDIR branch -D; \
		git -C $$GITDIR pull origin master; \
		git -C $$GITDIR branch; \
		rm -fv $(DLDIR)/$(1)/$(1)-*.tar.gz; \
	fi
	- rm -rv $(2)/output/build/$(1)-*
endef

define copy_to_outputs
	cp $(1) $(OUTPUTS)/$(addprefix $(PREFIX)-$(BRANCH_PREFIX), $(if $(2),$(2),$(notdir $(1))))
endef

.PHONY: buildroot

$(OUTPUTS):
	mkdir -p $(OUTPUTS)

$(DLDIR):
	mkdir -p $(DLDIR)

bootstrap.buildroot.stamp:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) defconfig
	touch $@

buildroot: $(OUTPUTS) $(DLDIR)
# Buildroot generates so much output drone ci can
# handle it, so tell make to be quiet
	$(MAKE) -s -C buildroot $(BUILDROOT_ARGS)

# For CI caching. Download all of the source so you
# can cache it and reuse it for then next build
buildroot-dl: $(OUTPUTS) $(DLDIR) bootstrap.buildroot.stamp
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) source
	$(call update_git_package,linux,buildroot)
	$(call update_git_package,uboot,buildroot)

buildroot-menuconfig: bootstrap.buildroot.stamp
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) menuconfig

buildroot-savedefconfig: bootstrap.buildroot.stamp
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) savedefconfig

# Save a toolchain so that other people don't need to build
# it..
buildroot-toolchain: $(OUTPUTS) bootstrap.buildroot.stamp
	$(MAKE) -C buildroot sdk
	cp buildroot/output/images/$(TOOLCHAIN) $(OUTPUTS)/$(PREFIX)-toolchain.tar.gz

buildroot-linux-menuconfig: bootstrap.buildroot.stamp
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) linux-menuconfig

buildroot-linux-savedefconfig: bootstrap.buildroot.stamp
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) linux-update-defconfig

buildroot-clean:
	$(MAKE) -C buildroot $(BUILDROOT_ARGS) clean

clean: buildroot-clean
