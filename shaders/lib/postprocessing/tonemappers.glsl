
#define TonemapExposure 1.1 
#define TonemapWhiteCurve 70.4 
#define TonemapLowerCurve 1.0 
#define TonemapUpperCurve 0.5 

vec3 BSLTonemap(vec3 x){
	x = TonemapExposure * x;
	x = x / pow(pow(x, vec3(TonemapWhiteCurve)) + 1.0, vec3(1.0 / TonemapWhiteCurve));
	x = pow(x, mix(vec3(TonemapLowerCurve), vec3(TonemapUpperCurve), sqrt(x)));
	return x;
}

vec3 filmic(vec3 x) {
  vec3 X = max(vec3(0.0), x - 0.004);
  vec3 result = (X * (6.2 * X + 0.5)) / (X * (6.2 * X + 1.7) + 0.06);
  return pow(result, vec3(2.2));
}

vec3 aces(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}
