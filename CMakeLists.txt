project(symba)
cmake_minimum_required (VERSION 2.8.11)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR ) 
  message (FATAL_ERROR
    "In-source builds are not allowed. Please clean your source tree and try again.")  
endif()

# Add path for custom modules
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")



include(ExternalProject)
set_property(DIRECTORY PROPERTY EP_STEP_TARGETS configure build test)
ExternalProject_Add(z3
  GIT_REPOSITORY https://git01.codeplex.com/forks/arie/optiz3
  GIT_TAG optiz3
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} 
  ./configure -p <INSTALL_DIR> -b build --staticlib
  BUILD_COMMAND make -j3 -C build
  INSTALL_COMMAND make -C build install
  LOG_CONFIGURE 1
  LOG_INSTALL 1
  LOG_BUILD 1)
ExternalProject_Get_Property (z3 INSTALL_DIR)
set(Z3_ROOT ${INSTALL_DIR})

find_package (Gmp REQUIRED)
get_filename_component (GMP_SEARCH_PATH ${GMP_INCLUDE_DIR} PATH)
ExternalProject_Add(apron
  GIT_REPOSITORY https://arieg@bitbucket.org/arieg/apron.git
  GIT_TAG 708af3860585ffb747668c4deb34bccc111cf687
  CONFIGURE_COMMAND echo "Apron does not need a configure"
  BUILD_IN_SOURCE 1
  BUILD_COMMAND make CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} 
  APRON_PREFIX=<INSTALL_DIR> GMP_PREFIX=${GMP_SEARCH_PATH}
  INSTALL_COMMAND make APRON_PREFIX=<INSTALL_DIR> GMP_PREFIX=/opt/local install
  LOG_CONFIGURE 1
  LOG_INSTALL 1
  LOG_BUILD 1)
ExternalProject_Get_Property (apron INSTALL_DIR)
set (APRON_ROOT ${INSTALL_DIR})

if (EXISTS "${CMAKE_SOURCE_DIR}/soplex/soplex-1.7.1.tgz")
  ExternalProject_Add(soplex
    URL "${CMAKE_SOURCE_DIR}/soplex/soplex-1.7.1.tgz"
    PATCH_COMMAND sh -c "cp ${CMAKE_SOURCE_DIR}/soplex/*clang* make"
    CONFIGURE_COMMAND echo "Soplex has no configure"
    BUILD_IN_SOURCE 1
    BUILD_COMMAND 
    make VERBOSE=1 CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} OPT=opt COMP=clang
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
ExternalProject_Add (llvm-2.9
  GIT_REPOSITORY https://arieg@bitbucket.org/arieg/llvm29.git
  GIT_TAG 09bda3ae687bc01293c1df072053c10db5f9c2a
  CMAKE_ARGS 
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}  
  -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
  -DLLVM_TARGETS_TO_BUILD:STRING=X86 -DLLVM_BUILD_POLLY:BOOL=OFF
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_INSTALL 1)
ExternalProject_Get_Property (llvm-2.9 INSTALL_DIR)
set (LLVM_ROOT ${INSTALL_DIR})

find_package(GlPk REQUIRED)
get_filename_component (GLPK_ROOT ${GLPK_INCLUDE_DIR} PATH) 


ExternalProject_Add (ufo
  DEPENDS z3 apron soplex llvm-2.9
  GIT_REPOSITORY https://arieg@bitbucket.org/arieg/ufo.git
  GIT_TAG popl14
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release 
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
  