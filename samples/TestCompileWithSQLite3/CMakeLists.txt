# ****************************************************************************
#  Project:  LibCMaker_SQLite3
#  Purpose:  A CMake build script for SQLite3 library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
#
#    This file is part of the LibCMaker_SQLite3 project.
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

cmake_minimum_required(VERSION 3.3)

# TODO: C lang.
project(LibCMaker_SQLite3_Compile_Test CXX C)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(cmr_PRINT_DEBUG ON)


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")

include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)


#-----------------------------------------------------------------------
# Set vars to LibCMaker_SQLite3
#-----------------------------------------------------------------------

set(SQLITE3_lib_NAME     "SQLite3")
set(SQLITE3_lib_VERSION  "3.24.0")
set(SQLITE3_lib_DIR      "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_SQLite3")

# To use below for sample sources.
set(cmr_UNPACKED_DIR ${CMAKE_CURRENT_BINARY_DIR}/download/unpacked)

# To use our FindSQLite3.cmake.
list(APPEND CMAKE_MODULE_PATH "${SQLITE3_lib_DIR}/cmake/modules")

set(COPY_SQLITE3_CMAKE_BUILD_SCRIPTS ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

#option(BUILD_SHARED_LIBS "build shared library" ${BUILD_SHARED_LIBS})
option(SQLITE_BUILD_SHELL "Build the sqlite3 shell" ON)

option(SQLITE_THREADSAFE "build a thread-safe library" ON)
option(SQLITE_OMIT_LOAD_EXTENSION
  "omits the entire extension loading mechanism" OFF
)

option(SQLITE_ENABLE_FTS3
  "version 3 of the full-text search engine, see also SQLITE_ENABLE_FTS4 which enables FTS3 as well"
  OFF
)
option(SQLITE_ENABLE_FTS3_PARENTHESIS
  "modifies the query pattern parser in FTS3 such that it supports operators AND and NOT and also allows query expressions to contain nested parenthesis"
  OFF
)
option(SQLITE_ENABLE_FTS4
  "versions 3 and 4 of the full-text search engine" OFF
)
option(SQLITE_ENABLE_FTS5 "versions 5 of the full-text search engine" OFF)
option(SQLITE_ENABLE_ICU "the ICU extension to SQLite to be added" ON)
option(SQLITE_ENABLE_JSON1
  "the JSON SQL functions are added to the build automatically" OFF
)
option(SQLITE_ENABLE_RTREE "include support for the R*Tree index extension" OFF)
option(SQLITE_ENABLE_COLUMN_METADATA
  "include APIs that provide access to meta-data about tables and queries"
  OFF
)

option(SQLITE_DEBUG "Build SQLite debug features" OFF)
option(SQLITE_MEMDEBUG "Build SQLite memory debug features" OFF)


#-----------------------------------------------------------------------
# Build and install the ICU
#-----------------------------------------------------------------------

if(SQLITE_ENABLE_ICU)
  set(ICU_lib_NAME        "ICU")
  set(ICU_lib_VERSION     "61.1")
  set(ICU_lib_COMPONENTS  i18n uc data)
  set(ICU_lib_DIR         "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_ICU")

  # Used in 'cmr_build_rules_sqlite3.cmake'.
  set(LIBCMAKER_ICU_SRC_DIR ${ICU_lib_DIR})

  # To use our FindICU.cmake.
  list(APPEND CMAKE_MODULE_PATH "${ICU_lib_DIR}/cmake/modules")

  set(COPY_ICU_CMAKE_BUILD_SCRIPTS ON)

  # Library specific vars and options.

  # Enable cross compiling
  set(ICU_CROSS_COMPILING OFF)
  if(NOT ICU_CROSS_BUILDROOT)
    # Specify an absolute path to the build directory of an ICU built for the current platform
    set(ICU_CROSS_BUILDROOT "")
  endif()
  # Compile with strict compiler options
  set(ICU_ENABLE_STRICT ON)
  # Compile with 'm' library.
  set(ICU_USE_LIB_M OFF)
  # Enable auto cleanup of libraries
  set(ICU_ENABLE_AUTO_CLEANUP OFF)
  # Enable draft APIs (and internal APIs)
  set(ICU_ENABLE_DRAFT ON)
  # Add a version suffix to symbols
  set(ICU_ENABLE_RENAMING ON)
  # Enable function and data tracing
  set(ICU_ENABLE_TRACING OFF)
  # Enable plugins
  set(ICU_ENABLE_PLUGINS OFF)
  # Disable dynamic loading
  set(ICU_DISABLE_DYLOAD ON)
  # Use rpath when linking
  set(ICU_ENABLE_RPATH OFF)
  # Compile with 'wxs' or 'w' libraries.
  set(ICU_USE_WCS_OR_W_LIB OFF)
  # Build ICU extras
  set(ICU_ENABLE_EXTRAS OFF) # TODO: not released
  # Build ICU's icuio library
  set(ICU_ENABLE_ICUIO ON)
  # Build ICU's Paragraph Layout library. icu-le-hb must be available via find_package(icu-le-hb). See http://harfbuzz.org
  set(ICU_ENABLE_LAYOUTEX OFF) # TODO: not released
  # ...
  #set(ICU_ENABLE_LAYOUT OFF)
  # Build ICU's tools
  set(ICU_ENABLE_TOOLS ON)
  # Specify how to package ICU data. Possible values: files, archive, library, static, auto. See http://userguide.icu-project.org/icudata for more info
  set(ICU_DATA_PACKAGING "auto") # TODO: 'files' mode is not released
  # Tag a suffix to the library names
  set(ICU_LIBRARY_SUFFIX "")
  # Build ICU tests
  set(ICU_ENABLE_TESTS OFF) # TODO: not released
  # Build ICU samples
  set(ICU_ENABLE_SAMPLES OFF) # TODO: not released

  find_package(Threads REQUIRED)

  include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
  cmr_find_package(
    LibCMaker_DIR   ${LibCMaker_DIR}
    NAME            ${ICU_lib_NAME}
    VERSION         ${ICU_lib_VERSION}
    COMPONENTS      ${ICU_lib_COMPONENTS}
    LIB_DIR         ${ICU_lib_DIR}
    REQUIRED
  )
endif()


#-----------------------------------------------------------------------
# Build, install and find the SQLite3
#-----------------------------------------------------------------------

# Make build and install the library at a config CMake phase.
#include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${SQLITE3_lib_NAME}
  VERSION         ${SQLITE3_lib_VERSION}
  LIB_DIR         ${SQLITE3_lib_DIR}
  REQUIRED
)


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Stub target. We use sqlite3 shell as sample.
add_custom_target(build_host_tools ALL
  COMMAND ${CMAKE_COMMAND} -E echo "All is ready."
)
