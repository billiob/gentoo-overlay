# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mercurial flag-o-matic

filter-ldflags "-Wl,-O1"

EHG_REPO_URI="http://opensound.hg.sourceforge.net:8000/hgroot/opensound/opensound"

DESCRIPTION="Open Sound System - portable, mixing-capable, high quality sound system for Unix."
HOMEPAGE="http://developer.opensound.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk salsa"

DEPEND="sys-apps/gawk
	>=sys-kernel/linux-headers-2.6.11
	gtk? ( >=x11-libs/gtk+-2 )
	salsa? ( media-libs/alsa-lib )
	!media-sound/oss"

RDEPEND="${DEPEND}"

S="${WORKDIR}/build"

src_unpack() {
	mercurial_src_unpack
	mkdir "${WORKDIR}/build"

	einfo "Replacing init script with gentoo friendly one..."
	cp "${FILESDIR}/oss" "${WORKDIR}/opensound/setup/Linux/oss/etc/S89oss"
	cd "$WORKDIR"
}

src_configure() {
	local myconf="--enable-libsalsa=$(use salsa && echo YES || echo NO)"

	# Configure has to be run from build dir with full path.
	cd "${WORKDIR}/build"
	"${WORKDIR}/opensound/configure" ${myconf} || die "configure failed"
}

src_compile() {
	einfo "Stripping compiler flags..."
	sed -i -e 's/-D_KERNEL//' \
		"${WORKDIR}/build/Makefile"

	emake build || die "emake build failed"
}

src_install() {
	newinitd "${FILESDIR}"/oss oss
	cd "${WORKDIR}/build"
	cp -R prototype/* "${D}"
}

pkg_postinst() {
	elog "To use OSSv4 for the first time you must run"
	elog "# /etc/init.d/oss start "
	elog ""
	elog "If you are upgrading, run"
	elog "# /etc/init.d/oss restart "
	elog ""
	elog "Enjoy OSSv4 !"
}
