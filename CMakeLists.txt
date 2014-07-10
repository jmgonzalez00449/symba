project(symba)
cmake_minimum_required (VERSION 2.8.11)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR ) 
  message (FATAL_ERROR
    "In-source builds are not allowed. Please clean your source tree and try again.")  
endif()

set (CMAKE_BUILD_TYPE "Release" CACHE STRING "Build mode: Release, Debug")
# Add path for custom modules
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set (Z3_DEBUG "-d")
else()
  set (Z3_DEBUG "")
endif()

set (Z3_TAG "optiz3" CACHE STRING "Z3 git tag to use")
include(ExternalProject)
set_property(DIRECTORY PROPERTY EP_STEP_TARGETS configure build test)
ExternalProject_Add(z3
  GIT_REPOSITORY https://bitbucket.org/arieg/optiz3  
  GIT_TAG ${Z3_TAG}
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} 
  ./configure -p <INSTALL_DIR> -b build --staticlib ${Z3_DEBUG}
  BUILD_COMMAND make -j3 -C build 
  INSTALL_COMMAND make -C build install
  LOG_CONFIGURE 1
  LOG_INSTALL 1
  LOG_BUILD 1)
ExternalProject_Get_Property (z3 INSTALL_DIR)
set(Z3_ROOT ${INSTALL_DIR})

find_package (Gmp REQUIRED)
get_filename_component (GMP_SEARCH_PATH ${GMP_INCLUDE_DIR} PATH)

option(WITH_APRON "Compile with Apron library" OFF)
if (WITH_APRON)
  ExternalProject_Add(apron
    GIT_REPOSITORY https://arieg@bitbucket.org/arieg/apron.git
    GIT_TAG 708af3860585ffb747668c4deb34bccc111cf687
    CONFIGURE_COMMAND echo "Apron does not need a configure"
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} 
    APRON_PREFIX=<INSTALL_DIR> GMP_PREFIX=${GMP_SEARCH_PATH}
    INSTALL_COMMAND 
    make APRON_PREFIX=<INSTALL_DIR> GMP_PREFIX=${GMP_SEARCH_PATH} install
    LOG_CONFIGURE 1
    LOG_INSTALL 1
    LOG_BUILD 1)
  ExternalProject_Get_Property (apron INSTALL_DIR)
  set (APRON_ROOT ${INSTALL_DIR})
endif()

option(WITH_SOPLEX "Compile with Soplex library" OFF)
if (WITH_SOPLEX)
  if (EXISTS "${CMAKE_SOURCE_DIR}/soplex/soplex-1.7.1.tgz")
    ExternalProject_Add(soplex
      URL "${CMAKE_SOURCE_DIR}/soplex/soplex-1.7.1.tgz"
      PATCH_COMMAND sh -c "cp ${CMAKE_SOURCE_DIR}/soplex/*clang* make"
      CONFIGURE_COMMAND echo "Soplex has no configure"
      BUILD_IN_SOURCE 1
      BUILD_COMMAND 
      make VERBOSE=1 
      CC=${CMAKE_C_COMPILER} 
      CXX=${CMAKE_CXX_COMPILER} OPT=opt COMP=clang
      INSTALL_COMMAND make install INSTALLDIR=<INSTALL_DIR> OPT=opt COMP=clang
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1)
    ExternalProject_Get_Property (soplex SOURCE_DIR)
    set (SOPLEX_ROOT ${SOURCE_DIR})
  else()
    message (FATAL_ERROR "Download soplex-1.7.1.tgz from "
      "http://soplex.zib.de/download.php?fname=soplex-1.7.1.tgz "
      "and copy it to ${CMAKE_SOURCE_DIR}/soplex/soplex-1.7.1.tgz")
  endif()
endif()

ExternalProject_Add (llvm-2.9
  GIT_REPOSITORY https://arieg@bitbucket.org/arieg/llvm29.git
  GIT_TAG 09bda3ae687bc01293c1df072053c10db5f9c2a
  CMAKE_ARGS 
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}  
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} 
  -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  -DLLVM_TARGETS_TO_BUILD:STRING=X86 -DLLVM_BUILD_POLLY:BOOL=OFF
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_INSTALL 1)
ExternalProject_Get_Property (llvm-2.9 INSTALL_DIR)
set (LLVM_ROOT ${INSTALL_DIR})

find_package(GlPk REQUIRED)
get_filename_component (GLPK_ROOT ${GLPK_INCLUDE_DIR} PATH) 

set (UFO_DEPENDS "z3;llvm-2.9")
if (WITH_SOPLEX)
  list (APPEND UFO_DEPENDS "soplex")
endif()
if (WITH_APRON)
  list (APPEND UFO_DEPENDS "apron")
endif()

set (UFO_TAG "popl14" CACHE STRING "Ufo git tag to use")
ExternalProject_Add (ufo
  DEPENDS ${UFO_DEPENDS}
  GIT_REPOSITORY https://arieg@bitbucket.org/arieg/ufo.git
  GIT_TAG ${UFO_TAG}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}  
  -DLLVM_CONFIG_EXECUTABLE=${LLVM_ROOT}/bin/llvm-config 
  -DZ3_ROOT=${Z3_ROOT} 
  -DAPRON_ROOT=${APRON_ROOT}
  -DSOPLEX_ROOT=${SOPLEX_ROOT} 
  -DGLPK_ROOT=${GLPK_ROOT}
  -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  LOG_CONFIGURE 1
  LOG_INSTALL 1
  LOG_BUILD 1)
  
