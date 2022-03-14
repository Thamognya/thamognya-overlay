# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Like neofetch but faster"
HOMEPAGE="https://github.com/LinusDierheimer/fastfetch"
if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/LinusDierheimer/fastfetch.git"
else
	COMMIT="00fdb8a0c40b4894a111d7acf63f30a9a9ebca80"
	VERSION_REV="00fdb8a"
	SRC_URI="https://github.com/LinusDierheimer/fastfetch/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="X gnome pci vulkan wayland xcb xfce xrandr"

# note - qa-vdb will always report errors because fastfetch loads the libs dynamically
RDEPEND="
	X? ( x11-libs/libX11 )
	gnome? (
		dev-libs/glib
		gnome-base/dconf
	)
	pci? ( sys-apps/pciutils )
	vulkan? ( media-libs/vulkan-loader )
	wayland? ( dev-libs/wayland )
	xcb? ( x11-libs/libxcb )
	xfce? ( xfce-base/xfconf )
	xrandr? ( x11-libs/libXrandr )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

REQUIRED_USE="xrandr? ( X )"

src_configure() {
	local mycmakeargs=(
		-DENABLE_RPM=no
		-DENABLE_VULKAN=$(usex vulkan)
		-DENABLE_WAYLAND=$(usex wayland)
		-DENABLE_XCB_RANDR=$(usex xcb)
		-DENABLE_XCB=$(usex xcb)
		-DENABLE_XRANDR=$(usex xrandr)
		-DENABLE_X11=$(usex X)
		-DENABLE_GIO=$(usex gnome)
		-DENABLE_DCONF=$(usex gnome)
		-DENABLE_XFCONF=$(usex xfce)
	)

	if [[ ${PV} == *9999 ]]; then
		elog "REV=\"r$(git rev-list --count HEAD)\""
		elog "COMMIT=\"$(git rev-parse HEAD)\""
		elog "VERSION_REV=\"$(git rev-parse --short HEAD)\""
	else
		# version comes from git, fake it
		local project_version_major=$(ver_cut 2)
		mycmakeargs+=(
			-DPROJECT_VERSION="r${project_version_major}.${VERSION_REV}"
			-DPROJECT_VERSION_MAJOR="${project_version_major}"
		)
	fi

	cmake_src_configure
}
