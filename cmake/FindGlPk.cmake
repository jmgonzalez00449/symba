# Find Glpk


set(GLPK_ROOT "" CACHE PATH "Root of Glpk compiled source tree.")


find_path(GLPK_INCLUDE_DIR NAMES glpk.h PATHS ${GLPK_ROOT}/include)
find_library(GLPK_LIBRARY NAMES glpk PATHS ${GLPK_ROOT}/lib)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(GlPk
  REQUIRED_VARS GLPK_LIBRARY GLPK_INCLUDE_DIR)

mark_as_advanced(GLPK_LIBRARY GLPK_INCLUDE_DIR)
