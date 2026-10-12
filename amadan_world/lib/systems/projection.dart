/// Perspective ground projection. The camera floats [camHeight] units above
/// the ground, [backDist] units behind the focus point, looking north
/// (negative world y). World x maps to screen x, world y recedes into depth.
class Projection {
  static const double backDist = 430;
  static const double camHeight = 172;
  static const double nearClip = 70;
  static const double farClip = 2700;

  double width = 1;
  double height = 1;
  double horizonY = 0;
  double baseFocal = 1;
  double focal = 1;
  double zoom = 1;

  double camX = 0;
  double camY = 0;

  // Output of the last [project] call.
  double sx = 0;
  double sy = 0;
  double scale = 0;

  void configure(double w, double h) {
    width = w;
    height = h;
    horizonY = h * 0.2;
    baseFocal = (h * 0.66 - horizonY) * backDist / camHeight;
    focal = baseFocal * zoom;
  }

  void setZoom(double z) {
    zoom = z;
    focal = baseFocal * zoom;
  }

  /// Forward distance from the camera to world row [y].
  double depthOf(double y) => camY + backDist - y;

  /// Projects a world point. Returns false when it lies behind the near plane.
  bool project(double x, double y, double z) {
    final f = camY + backDist - y;
    if (f < nearClip) return false;
    final s = focal / f;
    scale = s;
    sx = width * 0.5 + (x - camX) * s;
    sy = horizonY + (camHeight - z) * s;
    return true;
  }

  /// Screen y of the ground at forward distance [f].
  double groundYAt(double f) => horizonY + camHeight * focal / f;

  /// Forward distance of the ground at screen row [screenY].
  double depthAtScreenY(double screenY) {
    final d = screenY - horizonY;
    if (d <= 0) return farClip;
    return camHeight * focal / d;
  }

  bool onScreen(double margin) =>
      sx > -margin && sx < width + margin && sy > -margin && sy < height + margin * 2;
}
