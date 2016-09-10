################################################################################
#
# python-cython
#
################################################################################

PYTHON_CYTHON_VERSION = 0.21.2
PYTHON_CYTHON_SOURCE = Cython-$(PYTHON_CYTHON_VERSION).tar.gz
PYTHON_CYTHON_SITE = http://cython.org/release/
PYTHON_CYTHON_SETUP_TYPE = distutils
PYTHON_CYTHON_LICENSE = Apache-2.0
PYTHON_CYTHON_LICENSE_FILES = LICENSE.txt

$(eval $(python-package))
$(eval $(host-python-package))
