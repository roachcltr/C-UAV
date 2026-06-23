file(REMOVE_RECURSE
  "RadarFrontend/qml/main.qml"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/TmmrRadarUI_tooling.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
