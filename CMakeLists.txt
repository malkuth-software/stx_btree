cmake_minimum_required(VERSION 3.21)
project(stx_btree VERSION 0.1.0 LANGUAGES CXX)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
option(STX_BTREE_BUILD_TESTS "Build the ordinary tests" ${PROJECT_IS_TOP_LEVEL})
option(STX_BTREE_BUILD_BENCHMARKS "Build the benchmark program" ${PROJECT_IS_TOP_LEVEL})
# The sanitizer tree beside the ordinary one (house style 5): ASan, UBSan and,
# where the runtime has it, LSan; any report fails the run.
option(STX_BTREE_SANITIZE "Build with AddressSanitizer and UndefinedBehaviorSanitizer" OFF)

# Header-only: the maps are templates over key, value and allocator.
add_library(stx_btree INTERFACE)
add_library(stx_btree::stx_btree ALIAS stx_btree)
target_compile_features(stx_btree INTERFACE cxx_std_20)
target_include_directories(stx_btree INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
find_package(Threads REQUIRED)
target_link_libraries(stx_btree INTERFACE Threads::Threads)

set(STX_BTREE_WARNINGS -Wall -Wextra -Wpedantic -Wshadow -Werror)
set(STX_BTREE_SANITIZER_FLAGS
    -fsanitize=address,undefined -fno-sanitize-recover=undefined -fno-omit-frame-pointer)

function(stx_btree_program target)
    target_link_libraries(${target} PRIVATE stx_btree)
    set_target_properties(${target} PROPERTIES CXX_EXTENSIONS OFF)
    if(NOT MSVC)
        target_compile_options(${target} PRIVATE ${STX_BTREE_WARNINGS})
    endif()
    if(STX_BTREE_SANITIZE)
        target_compile_options(${target} PRIVATE ${STX_BTREE_SANITIZER_FLAGS})
        target_link_options(${target} PRIVATE -fsanitize=address,undefined)
    endif()
endfunction()

if(STX_BTREE_BUILD_TESTS)
    enable_testing()
    add_executable(stx_btree_unsync_map_test tests/unsync_map_test.cpp)
    target_include_directories(stx_btree_unsync_map_test PRIVATE tests)
    stx_btree_program(stx_btree_unsync_map_test)
    add_test(NAME stx_btree_unsync_map_test COMMAND stx_btree_unsync_map_test)
    add_executable(stx_btree_shared_map_test tests/bbtree_map_test.cpp)
    target_include_directories(stx_btree_shared_map_test PRIVATE tests)
    stx_btree_program(stx_btree_shared_map_test)
    add_test(NAME stx_btree_shared_map_test COMMAND stx_btree_shared_map_test)
endif()

if(STX_BTREE_BUILD_BENCHMARKS)
    add_executable(stx_btree_bench benchmarks/cpp/stx_btree_bench.cpp)
    stx_btree_program(stx_btree_bench)
endif()

install(TARGETS stx_btree EXPORT stx_btreeTargets)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES LICENSE-MIT LICENSE-APACHE NOTICE PROVENANCE.md
    DESTINATION ${CMAKE_INSTALL_DATADIR}/licenses/stx_btree)
install(EXPORT stx_btreeTargets NAMESPACE stx_btree:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/stx_btree)
configure_package_config_file(cmake/stx_btreeConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/stx_btreeConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/stx_btree)
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/stx_btreeConfigVersion.cmake
    VERSION ${PROJECT_VERSION} COMPATIBILITY SameMinorVersion ARCH_INDEPENDENT)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/stx_btreeConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/stx_btreeConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/stx_btree)
