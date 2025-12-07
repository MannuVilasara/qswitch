cmake_minimum_required(VERSION 3.15)
project(qswitch-go NONE)

# Path to Go executable
set(GO_EXECUTABLE "go")

# Output directory for build products
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# -------------------------------
# Build Go binary
# -------------------------------
add_custom_command(
    OUTPUT ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qswitch
    COMMAND ${GO_EXECUTABLE} build -o ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qswitch .
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Building qswitch Go binary"
)

add_custom_target(qswitch ALL
    DEPENDS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qswitch
)

# -------------------------------
# Install binary with executable permissions
# -------------------------------
install(
    FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qswitch
    DESTINATION bin
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

# -------------------------------
# Install manpage
# -------------------------------
install(
    FILES ${CMAKE_SOURCE_DIR}/man/qswitch.1
    DESTINATION share/man/man1
)

# -------------------------------
# Shell completions
# -------------------------------
# Bash
install(
    FILES ${CMAKE_SOURCE_DIR}/completions/qswitch.bash
    DESTINATION share/bash-completion/completions
    RENAME qswitch
)

# Zsh
install(
    FILES ${CMAKE_SOURCE_DIR}/completions/qswitch.zsh
    DESTINATION share/zsh/site-functions
    RENAME _qswitch
)

# Fish
install(
    FILES ${CMAKE_SOURCE_DIR}/completions/qswitch.fish
    DESTINATION share/fish/vendor_completions.d
)
# -------------------------------
# QuickSwitchPanel QML
# -------------------------------
install(
    FILES ${CMAKE_SOURCE_DIR}/quickshell/shell.qml
    DESTINATION /etc/xdg/quickshell/qswitch/
    PERMISSIONS
        OWNER_READ OWNER_WRITE
        GROUP_READ
        WORLD_READ
)

# -------------------------------
# Flavour icons
# -------------------------------
install(
    DIRECTORY ${CMAKE_SOURCE_DIR}/quickshell/icons/
    DESTINATION /etc/xdg/quickshell/qswitch/icons/
    FILES_MATCHING PATTERN "*.svg"
    PERMISSIONS
        OWNER_READ OWNER_WRITE
        GROUP_READ
        WORLD_READ
)

install(CODE "execute_process(COMMAND chown -R root:root /etc/xdg/quickshell/qswitch/)")

# -------------------------------
# Uninstall Target
# -------------------------------
if(NOT TARGET uninstall)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        IMMEDIATE @ONLY)

    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
endif()
