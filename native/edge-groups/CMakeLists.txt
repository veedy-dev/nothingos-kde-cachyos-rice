cmake_minimum_required(VERSION 3.20)
project(nothingos_edge_groups LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.7 REQUIRED COMPONENTS Core DBus)

add_executable(nothingos-edge-groups main.cpp)
target_link_libraries(nothingos-edge-groups PRIVATE Qt6::Core Qt6::DBus)
