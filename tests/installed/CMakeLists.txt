cmake_minimum_required(VERSION 3.21)
project(stx_btree_installed_consumer LANGUAGES CXX)
# Uses only the installed package: no source path of the repository.
find_package(stx_btree 0.1 CONFIG REQUIRED)
add_executable(installed_consumer main.cpp)
target_link_libraries(installed_consumer PRIVATE stx_btree::stx_btree)
set_target_properties(installed_consumer PROPERTIES CXX_EXTENSIONS OFF)
enable_testing()
add_test(NAME installed_consumer COMMAND installed_consumer)
