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
    COMMAND ${GO_EXECUTABLE} build -o ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qswitch main.go
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    DEPENDS ${CMAKE_SOURCE_DIR}/main.go
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
# Fish completions
# -------------------------------
install(
    FILES ${CMAKE_SOURCE_DIR}/completions/qswitch.fish
    DESTINATION share/fish/vendor_completions.d
)

# -------------------------------
# Bash completions
# -------------------------------
install(
    FILES ${CMAKE_SOURCE_DIR}/completions/qswitch.bash
    DESTINATION share/bash-completion/completions
)

# -------------------------------
# Zsh completions
# -------------------------------
install(
    FILES ${CMAKE_SOURCE_DIR}/completions/_qswitch
    DESTINATION share/zsh/site-functions
)
