/// Initialization options for the Garmin SDK
class GarminInitializationOptions {
  /// The id of the companion application to communicate with
  final String applicationId;

  /// URL scheme of the iOS companion application
  final String urlScheme;

  /// Show UI to help the user resolve issues with Garmin Connect
  final bool autoUI;

  /// Tethering mode is set for connectivity with Garmin Connect.
  final bool tethered;

  /// Constructor
  GarminInitializationOptions({
    required this.applicationId,
    required this.urlScheme,
    this.autoUI = false,
    this.tethered = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'applicationId': applicationId,
        'urlScheme': urlScheme,
        'autoUI': autoUI,
        'tethered': tethered,
      };
}
