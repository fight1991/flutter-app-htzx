class EnvironmentConfig{
  ///是否是release
  static const bool isRelease = bool.fromEnvironment("IS_RELEASE",defaultValue: false);
  ///是否是本能设备
//  static const bool isBenNengDevice = bool.fromEnvironment("IS_BENNENG",defaultValue: true);
}