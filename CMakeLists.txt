cmake_minimum_required(VERSION 3.16)

project(UWS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets Concurrent LinguistTools)

qt_standard_project_setup(REQUIRES 6.5)


qt_add_executable(appUWS
    main.cpp
    uws.h uws.cpp

)
qt_add_resources(appUWS "conf"
    PREFIX "/" FILES qtquickcontrols2.conf
)

qt_add_qml_module(appUWS
    URI UWS
    VERSION 1.0
    QML_FILES Main.qml IndexPage.qml InteractivePage.qml
)

set_property(TARGET appUWS APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android

)
qt_add_translations(appUWS TS_FILES uws.ts
    RESOURCE_PREFIX "/translations"
)


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appUWS PROPERTIES
    #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appUWS
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)


target_link_libraries(appUWS
    PRIVATE Qt6::Quick Qt6::Widgets Qt6::Concurrent
)


include(GNUInstallDirs)
install(TARGETS appUWS
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
