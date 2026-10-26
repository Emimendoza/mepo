# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: sycl.eclass
# @MAINTAINER:
# @AUTHOR:
# @SUPPORTED_EAPIS: 7 8 9
# @BLURB: Common functions for sycl packages
# @DESCRIPTION:


# @ECLASS_VARIABLE: SYCL_ECLASS
# @DEPRECATED: none
# @DESCRIPTION:
# Only dpc++ is supported
: "${SYCL_ECLASS:=dpc++}"

case ${SYCL_ECLASS} in
	dpc++) ;;
	*)
		eerror "Unknown value for \${SYCL_ECLASS}"
		die "Value ${SYCL_ECLASS} is not supported"
		;;
esac

inherit flag-o-matic

sycl_src_prepare(){
	case ${SYCL_ECLASS} in
		dpc++)
			export CXX=dpclang++
			export CC=dpclang
			export LD=dpclang++
			append-ldflags -fsycl
			;;
		*)
			eerror "Unknown value for \${SYCL_ECLASS}"
			die "Value ${SYCL_ECLASS} is not supported"
			;;
	esac
}
