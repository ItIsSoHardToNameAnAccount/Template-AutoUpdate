# If Server use different OS with Embedded Device
# Change compile command to "cmake -DCMAKE_TOOLCHAIN_FILE=$WORK_TREE/toolchain.cmake -S $WORK_TREE -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Release"

# Set target OS
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Set cross compile tool chain
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)