# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

# You can find the version suffix in:
# https://apt.repos.intel.com/oneapi/dists/all/main/binary-amd64/Packages.bz2

PN_VER=$(ver_cut 1-2)
MY_PV=$(ver_cut 1-3)-$(ver_cut 4)
DESCRIPTION="Intel Math Kernel Library Sycl"
HOMEPAGE="https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html"
# Upstream packages are a mess -- and most of them are literally empty.
SRC_URI="
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-stats-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-vm-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-data-fitting-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-include-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-devel-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-blas-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-rng-${PN_VER}-${MY_PV}_amd64.deb
	https://apt.repos.intel.com/oneapi/pool/main/intel-oneapi-mkl-sycl-lapack-${PN_VER}-${MY_PV}_amd64.deb
"
S="${WORKDIR}"

LICENSE="ISSL"
SLOT="0/3"
KEYWORDS="~amd64"
IUSE="examples"
RESTRICT="strip"

RDEPEND="
	~sci-libs/mkl-${PV}
"
# bug #801460
BDEPEND="
	app-arch/xz-utils[extra-filters(+)]
	dev-util/patchelf
"

QA_PREBUILT="*"
QA_TEXTRELS="*"
QA_SONAME="*"

src_install() {
	local libdir=$(get_libdir)
	local libroot=opt/intel/oneapi/mkl/${PN_VER}/lib

	if ! use examples; then
		rm -rv "opt/intel/oneapi/mkl/${PN_VER}"/share/doc/mkl/examples || die
	fi


	if [ -d "${libroot}/pkgconfig" ];then
		# Symlink pkgconfig and cmake files
		pushd "${libroot}/pkgconfig" >/dev/null || die
		for file in *.pc; do
			dosym "../../../${libroot}/pkgconfig/${file}" \
				"/usr/${libdir}/pkgconfig/${file}"
		done
		popd >/dev/null || die
	fi

	if [ -d "${libroot}/cmake/mkl" ];then
		pushd "${libroot}/cmake/mkl" >/dev/null || die
		for file in *.cmake; do
			dosym "../../../../${libroot}/cmake/mkl/${file}" \
				"/usr/${libdir}/cmake/mkl/${file}"
		done
		popd >/dev/null || die
	fi
	# Some programs (llama-cpp) don't link the mkl_rt when they use mkl_sycl_blas
	pushd "${libroot}" || die
	patchelf --add-needed libmkl_rt.so libmkl_sycl_blas.so || die
	popd >/dev/null || die


	# Move everything over to the image directory
	mv "${S}/"* "${ED}" || die
}

