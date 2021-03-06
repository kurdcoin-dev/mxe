# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := lapack
$(PKG)_WEBSITE  := http://www.netlib.org/lapack/
$(PKG)_VERSION  := 3.6.0
$(PKG)_CHECKSUM := a9a0082c918fe14e377bbd570057616768dca76cbdc713457d8199aaa233ffc3
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tgz
$(PKG)_URL      := http://www.netlib.org/$(PKG)/$($(PKG)_FILE)
$(PKG)_URL_2    := https://ftp.eq.uc.pt/software/math/netlib/$(PKG)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc cblas

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.netlib.org/lapack/' | \
    $(SED) -n 's_.*>LAPACK, version \([0-9]\.[0-9]\.[0-9]\).*_\1_ip' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && '$(TARGET)-cmake' \
        -DCMAKE_AR='$(PREFIX)/bin/$(TARGET)-ar' \
        -DCMAKE_RANLIB='$(PREFIX)/bin/$(TARGET)-ranlib' \
        -DLAPACKE=ON \
        .
    cp '$(1)/LAPACKE/include/lapacke_mangling_with_flags.h' '$(1)/LAPACKE/include/lapacke_mangling.h'
    $(MAKE) -C '$(1)/SRC'     -j '$(JOBS)' install
    $(MAKE) -C '$(1)/LAPACKE' -j '$(JOBS)' install

    '$(TARGET)-gfortran' \
        -W -Wall -Werror -pedantic \
        '$(PWD)/src/$(PKG)-test.f' -o '$(PREFIX)/$(TARGET)/bin/test-lapack.exe' \
        -llapack

    '$(TARGET)-gcc' \
        -W -Wall -Werror -pedantic \
        '$(PWD)/src/$(PKG)-test.c' -o '$(PREFIX)/$(TARGET)/bin/test-lapacke.exe' \
        -llapacke -llapack -lcblas -lblas -lgfortran -lquadmath
endef
