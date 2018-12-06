#pragma glslify: isCloseEnough = require(./isCloseEnough.glsl)
#pragma glslify: ScaleStop = require(./ScaleStop.glsl)

// Define the following variables in the importing script (names can be whatever you want):
// const int SCALE_MAX_LENGTH = 16;
// const int SENTINEL_MAX_LENGTH = 4;
// Then link them the variables in this script, like this:
// #pragma glslify: computeColor = require('./path/to/computeColor.glsl',SCALE_MAX_LENGTH=yourvarname1,SENTINEL_MAX_LENGTH=yourvarname2)

vec4 computeColor(
  float inputVal,
  ScaleStop colorScale[SCALE_MAX_LENGTH],
  int colorScaleLength,
  ScaleStop sentinelValues[SENTINEL_MAX_LENGTH],
  int sentinelValuesLength
) {
  // First compare the value against any sentinel values.
  for (int i = 0; i < SENTINEL_MAX_LENGTH; ++i) {
    if (i == sentinelValuesLength) {
      break;
    }
    ScaleStop sentinel = sentinelValues[i];
    if (isCloseEnough(inputVal, sentinel.offset)) {
      return sentinel.color;
    }
  }

  if (inputVal < colorScale[0].offset) {
    // If value below color scale range, clamp to lowest color stop.
    return colorScale[0].color;
  } else {
    for (int i = 0; i < SCALE_MAX_LENGTH; ++i) {
      if (i == colorScaleLength) {
        // If value above color scale range, clamp to highest color stop.
        return colorScale[i - 1].color;
      } else if (inputVal <= colorScale[i + 1].offset) {
        float percent = (inputVal - colorScale[i].offset)
          / (colorScale[i + 1].offset - colorScale[i].offset);
        return mix(colorScale[i].color, colorScale[i + 1].color, percent);
      }
    }
  }
  // This code should be unreachable as long as colorScaleLength <= SCALE_MAX_LENGTH, but it's
  // needed to satisfy the IE/Edge linker, which otherwise throws "Internal linking error". My guess
  // is it can't otherwise determine whether this function is guaranteed to return a vec4.
  return vec4(1.0);
}

#pragma glslify: export(computeColor)
