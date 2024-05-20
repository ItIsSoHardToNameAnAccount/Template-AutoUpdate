#Set CMake minimum version
cmake_minimum_required( VERSION 3.15 )

#Set project name and version
project(AutoUpdate VERSION 0.0.1 LANGUAGES CXX)

#Use C++20
set(CMAKE_CXX_STANDARD 20)

#Official code, don't know why is needed
if(CMAKE_VERSION VERSION_LESS "3.7.0")
	set(CMAKE_INCLUDE_CURRENT_DIR ON)
endif()

set(HEADER_FILES
	#If use framewrok like Qt
)

set(SOURCE_FILES
	#Add other .cpp files here
)

#Set executable file
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	add_executable(${PROJECT_NAME} WIN32 ${HEADER_FILES} ${SOURCE_FILES} main.cpp)
else()
	add_executable(${PROJECT_NAME} ${HEADER_FILES} ${SOURCE_FILES} main.cpp)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE
	#Add include directories
	#${CMAKE_CURRENT_SOURCE_DIR}/your/file/paht
)

#target_precompile_headers(${PROJECT_NAME} PRIVATE PCH.h)

#target_link_libraries(${PROJECT_NAME} library_name)