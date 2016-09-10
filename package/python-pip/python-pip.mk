################################################################################
#
# python-pip
#
################################################################################

PYTHON_PIP_VERSION = 8.1.1
PYTHON_PIP_SOURCE = pip-$(PYTHON_PIP_VERSION).tar.gz
PYTHON_PIP_SITE = https://pypi.python.org/packages/source/p/pip
PYTHON_PIP_SETUP_TYPE = setuptools
PYTHON_PIP_LICENSE = Apache-2.0
PYTHON_PIP_LICENSE_FILES = LICENSE.txt

$(eval $(python-package))
$(eval $(host-python-package))
