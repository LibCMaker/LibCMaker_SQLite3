# ****************************************************************************
#  Project:  LibCMaker_SQLite
#  Purpose:  A CMake build script for SQLite library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
#
#    This file is part of the LibCMaker_SQLite project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

# Part of "LibCMaker/cmake/cmr_get_download_params.cmake".

  if(version VERSION_EQUAL "3.24.0")
    set(arch_file_sha
      "fed8b1c04c63ce200773586422c9976b54f408cc")
  endif()

  if(version VERSION_EQUAL "3.32.3")
    set(arch_file_sha
      "0c805bea134712a903290a26b2a61c3a8a3bd8cc")
  endif()

  include(cmr_get_version_parts)
  cmr_get_version_parts(${version} major minor patch tweak)
  foreach(ver_part minor patch tweak)
    if(${ver_part} LESS 10)
      set(${ver_part} "0${${ver_part}}")
    endif()
  endforeach()

  set(ver_code "${major}${minor}${patch}${tweak}")

  # https://www.sqlite.org/2018/sqlite-amalgamation-3240000.zip
  # https://www.sqlite.org/2020/sqlite-amalgamation-3320300.zip
  set(base_url "https://www.sqlite.org/2020")

  # Workaround for the macOS and iOS on the Travis CI.
  if($ENV{TRAVIS} AND APPLE)
    set(base_url
      "https://github.com/LibCMaker/LibCMaker_Lib_Sources/raw/master/SQLite3"
    )
  endif()

  set(src_dir_name    "sqlite-${version}")
  set(arch_file_name  "${src_dir_name}.zip")
  set(unpack_to_dir   "${unpacked_dir}/${src_dir_name}")

  set(${out_ARCH_SRC_URL}
    "${base_url}/sqlite-amalgamation-${ver_code}.zip" PARENT_SCOPE
  )
  set(${out_ARCH_DST_FILE}  "${download_dir}/${arch_file_name}" PARENT_SCOPE)
  set(${out_ARCH_FILE_SHA}  "${arch_file_sha}" PARENT_SCOPE)
  set(${out_SHA_ALG}        "SHA1" PARENT_SCOPE)
  set(${out_UNPACK_TO_DIR}  "${unpack_to_dir}" PARENT_SCOPE)
  set(${out_UNPACKED_SOURCES_DIR}
    "${unpack_to_dir}/sqlite-amalgamation-${ver_code}" PARENT_SCOPE
  )
  set(${out_VERSION_BUILD_DIR} "${build_dir}/${src_dir_name}" PARENT_SCOPE)
