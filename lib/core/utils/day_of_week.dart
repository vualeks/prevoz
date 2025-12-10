/// Serbian day of week names for API calls
enum SerbianDayOfWeek {
  ponedeljak, // Monday
  utorak, // Tuesday
  srijeda, // Wednesday
  cetvrtak, // Thursday
  petak, // Friday
  subota, // Saturday
  nedelja; // Sunday

  /// Get the Serbian day name with proper capitalization for API
  String get apiName {
    switch (this) {
      case SerbianDayOfWeek.ponedeljak:
        return 'Ponedjeljak';
      case SerbianDayOfWeek.utorak:
        return 'Utorak';
      case SerbianDayOfWeek.srijeda:
        return 'Srijeda';
      case SerbianDayOfWeek.cetvrtak:
        return 'Četvrtak';
      case SerbianDayOfWeek.petak:
        return 'Petak';
      case SerbianDayOfWeek.subota:
        return 'Subota';
      case SerbianDayOfWeek.nedelja:
        return 'Nedjelja';
    }
  }

  /// Get current day of week in Serbian
  static SerbianDayOfWeek get today {
    final now = DateTime.now();
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    switch (now.weekday) {
      case 1:
        return SerbianDayOfWeek.ponedeljak;
      case 2:
        return SerbianDayOfWeek.utorak;
      case 3:
        return SerbianDayOfWeek.srijeda;
      case 4:
        return SerbianDayOfWeek.cetvrtak;
      case 5:
        return SerbianDayOfWeek.petak;
      case 6:
        return SerbianDayOfWeek.subota;
      case 7:
        return SerbianDayOfWeek.nedelja;
      default:
        return SerbianDayOfWeek.ponedeljak;
    }
  }
}
