# ****************************************************************************
#  Project:  LibCMaker_SQLite3
#  Purpose:  A CMake build script for SQLite3 library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

#-----------------------------------------------------------------------
# The file is an example of the convenient script for the library build.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Lib's name, version, paths
#-----------------------------------------------------------------------

set(SQLITE3_lib_NAME "SQLite3")
set(SQLITE3_lib_VERSION "3.32.3" CACHE STRING "SQLITE3_lib_VERSION")
set(SQLITE3_lib_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "SQLITE3_lib_DIR")

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${SQLITE3_lib_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

option(COPY_SQLITE3_CMAKE_BUILD_SCRIPTS "COPY_SQLITE3_CMAKE_BUILD_SCRIPTS" ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

#option(BUILD_SHARED_LIBS "build shared library" ${BUILD_SHARED_LIBS})
option(SQLITE_BUILD_SHELL "Build the sqlite3 shell" OFF)

option(SQLITE_THREADSAFE "build a thread-safe library" ON)
option(SQLITE_OMIT_LOAD_EXTENSION
  "omits the entire extension loading mechanism" ON
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
option(SQLITE_ENABLE_ICU "the ICU extension to SQLite to be added" OFF)
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
# Build, install and find the library
#-----------------------------------------------------------------------

if(SQLITE_ENABLE_ICU)
  # Used in 'cmr_build_rules_sqlite3.cmake'.
  set(LIBCMAKER_ICU_SRC_DIR ${ICU_lib_DIR} CACHE PATH "LIBCMAKER_ICU_SRC_DIR")
endif()

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${SQLITE3_lib_NAME}
  VERSION         ${SQLITE3_lib_VERSION}
  LIB_DIR         ${SQLITE3_lib_DIR}
  REQUIRED
  CONFIG
  NOT_USE_VERSION_IN_FIND_PACKAGE
)
