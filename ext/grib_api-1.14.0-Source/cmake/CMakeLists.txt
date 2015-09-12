file( GLOB_RECURSE ecbuild_support_files  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*" )

ecbuild_add_resources(  TARGET ${PROJECT_NAME}_ecbuild_support_files
						SOURCES_PACK
							${ecbuild_support_files} )
