cmake_minimum_required(VERSION 3.16)

project(QuickCut LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 找到 Qt
find_package(Qt6 COMPONENTS Widgets REQUIRED)

# 添加源文件
add_executable(quickcut
    src/main.cpp
)

# 链接 Qt 库
target_link_libraries(quickcut PRIVATE Qt6::Widgets)
