### adds uninstall target ###############

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/ecbuild_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/ecbuild_uninstall.cmake" IMMEDIATE @ONLY)

add_custom_target( uninstall "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/ecbuild_uninstall.cmake")
