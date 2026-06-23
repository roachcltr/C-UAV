cmake_minimum_required(VERSION 3.16)
project(TmmrRadarUI VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Discover required Qt6 components
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Network)

# Manually enable Qt's auto-compilation tools (Compatible with Qt 6.2)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Define source execution links
qt_add_executable(TmmrRadarUI
    src/main.cpp
    src/udplistener.h
    src/udplistener.cpp
)

# Embed your graphical view definitions
qt_add_qml_module(TmmrRadarUI
    URI RadarFrontend
    VERSION 1.0
    QML_FILES qml/main.qml
)

# Link appropriate runtime libraries
target_link_libraries(TmmrRadarUI PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Network
)