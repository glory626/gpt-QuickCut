cmake_minimum_required(VERSION 3.20)
project(QuickCut LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Multimedia MultimediaWidgets)

add_executable(quickcut
    src/main.cpp
    src/MainWindow.h
    src/MainWindow.cpp
    src/TimelineModel.h
    src/TimelineModel.cpp
    src/FfmpegExporter.h
    src/FfmpegExporter.cpp
)

target_include_directories(quickcut PRIVATE src)

target_link_libraries(quickcut PRIVATE
    Qt6::Widgets
    Qt6::Multimedia
    Qt6::MultimediaWidgets
)

if (WIN32)
    target_link_options(quickcut PRIVATE /SUBSYSTEM:CONSOLE)
endif()
