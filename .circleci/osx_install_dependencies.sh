#! /bin/bash
#------------------------------------------------------------------------------
# Bash script to install osx dependencies
#
# The documentation for solidity is hosted at:
#
#     https://docs.soliditylang.org
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2016-2019 solidity contributors.
# ------------------------------------------------------------------------------

# note that the following directories may be cached by circleci:
# - /usr/local/bin
# - /usr/local/sbin
# - /usr/local/lib
# - /usr/local/include
# - /usr/local/Cellar
# - /usr/local/Homebrew

set -eu

function validate_checksum {
  local package="$1"
  local expected_checksum="$2"

  local actual_checksum
  actual_checksum=$(sha256sum "$package")
  if [[ $actual_checksum != "${expected_checksum}  ${package}" ]]
  then
    >&2 echo "ERROR: Wrong checksum for package $package."
    >&2 echo "Actual:   $actual_checksum"
    >&2 echo "Expected: $expected_checksum"
    exit 1
  fi
}

if [ ! -f /usr/local/lib/libz3.a ] # if this file does not exists (cache was not restored), rebuild dependencies
then
  brew unlink python
  brew install boost
  brew install cmake
  brew install wget
  brew install coreutils
  brew install diffutils
  ./scripts/install_obsolete_jsoncpp_1_7_4.sh

  # z3
  z3_version="4.11.0"
  z3_dir="z3-${z3_version}-x64-osx-10.16"
  z3_package="${z3_dir}.zip"
  wget "https://github.com/Z3Prover/z3/releases/download/z3-${z3_version}/${z3_package}"
  validate_checksum "$z3_package" b6a4a6d587e4bfb0643db81129f0f447692fae13d4bd1bd4d93f1c0301b75ffc
  unzip "$z3_package"
  rm "$z3_package"
  cp "${z3_dir}/bin/libz3.a" /usr/local/lib
  cp "${z3_dir}/bin/z3" /usr/local/bin
  cp "${z3_dir}/include/"* /usr/local/include
  rm -r "$z3_dir"

  # evmone
  evmone_version="0.9.1"
  evmone_package="evmone-${evmone_version}-darwin-x86_64.tar.gz"
  wget "https://github.com/ethereum/evmone/releases/download/v${evmone_version}/${evmone_package}"
  validate_checksum "$evmone_package" 70420a893a9b1036fcb63526b806d97658db8c373bcab1c3e8382594dc8593e4
  tar xzpf "$evmone_package" -C /usr/local
  rm "$evmone_package"

  # hera
  hera_version="0.6.0"
  hera_package="hera-${hera_version}-darwin-x86_64.tar.gz"
  wget "https://github.com/ewasm/hera/releases/download/v${hera_version}/${hera_package}"
  validate_checksum "$hera_package" 82ee57404862705ab314f7a4d04bf2cf29d71e8d209850d66c125527cd287f37
  tar xzpf "$hera_package" -C /usr/local
  rm "$hera_package"
fi
