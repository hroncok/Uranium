enable_testing()
include(CMakeParseArguments)

function(uranium_add_test)
    set(_single_args NAME DIRECTORY PYTHONPATH)
    cmake_parse_arguments("" "" "${_single_args}" "" ${ARGN})

    if(NOT _NAME)
        message(FATAL_ERROR "UraniumAddTest requires a test name argument")
    endif()

    if(NOT _DIRECTORY)
        message(FATAL_ERROR "UraniumAddTest requires a directory to test")
    endif()

    if(NOT _PYTHONPATH)
        set(_PYTHONPATH ${_DIRECTORY})
    endif()

    if(WIN32)
        string(REPLACE "|" "\\;" _PYTHONPATH ${_PYTHONPATH})
    else()
        string(REPLACE "|" ":" _PYTHONPATH ${_PYTHONPATH})
    endif()

    add_test(
        NAME ${_NAME}
        COMMAND ${PYTHON_EXECUTABLE} -m pytest --junitxml=${CMAKE_BINARY_DIR}/junit-${_NAME}.xml ${_DIRECTORY}
    )
    set_tests_properties(${_NAME} PROPERTIES ENVIRONMENT LANG=C)
    set_tests_properties(${_NAME} PROPERTIES ENVIRONMENT "PYTHONPATH=${_PYTHONPATH}")
endfunction()

uranium_add_test(NAME pytest-main DIRECTORY ${CMAKE_SOURCE_DIR}/tests PYTHONPATH ${CMAKE_SOURCE_DIR})

file(GLOB_RECURSE _plugins plugins/*/__init__.py)
foreach(_plugin ${_plugins})
    get_filename_component(_plugin_directory ${_plugin} DIRECTORY)
    if(EXISTS ${_plugin_directory}/tests)
        get_filename_component(_plugin_name ${_plugin_directory} NAME)
        uranium_add_test(NAME pytest-${_plugin_name} DIRECTORY ${_plugin_directory} PYTHONPATH "${CMAKE_SOURCE_DIR}|${_plugin_directory}")
    endif()
endforeach()
