################################################################################
#
# confd
#
################################################################################

CONFD_VERSION = v0.12.0-alpha3
CONFD_SITE = https://github.com/kelseyhightower/confd/archive
CONFD_SOURCE = $(CONFD_VERSION).tar.gz

CONFD_LICENSE = Apache-2.0
CONFD_LICENSE_FILES = LICENSE

CONFD_DEPENDENCIES = host-go docker-engine

CONFD_MAKE_ENV = \
	$(HOST_GO_TARGET_ENV) \
	GOBIN="$(@D)/bin" \
	GOPATH="$(@D)/gopath" \
	CGO_ENABLED=0

define CONFD_CONFIGURE_CMDS
        # Put sources at prescribed GOPATH location.
	mkdir -p $(@D)/gopath/src
	ln -s $(DOCKER_ENGINE_SRCDIR)/vendor/src/github.com $(@D)/gopath/src/github.com
	ln -s $(DOCKER_ENGINE_SRCDIR)/vendor/src/golang.org $(@D)/gopath/src/golang.org
	mkdir -p $(@D)/gopath/src/github.com/kelseyhightower
	ln -s $(@D) $(@D)/gopath/src/github.com/kelseyhightower/confd
endef

define CONFD_BUILD_CMDS
	cd $(@D) && $(CONFD_MAKE_ENV) $(HOST_GO_ROOT)/bin/go \
		build -v -x -o $(@D)/bin/confd .
endef

define CONFD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/confd $(TARGET_DIR)/usr/bin/confd
endef

$(eval $(generic-package))
