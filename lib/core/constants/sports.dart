import '../models/sport_item.dart';
import '../models/sport_type.dart';

/// List of all available sports in the app.
const List<SportItem> sportsList = [
  SportItem(
    type: SportType.football,
    title: 'كرة قدم',
    iconPath: 'assets/icons/Football.png',
  ),
  SportItem(
    type: SportType.tennis,
    title: 'تنس',
    iconPath: 'assets/icons/tennis-racket.png',
  ),
  SportItem(
    type: SportType.tableTennis,
    title: 'تنس طاولة',
    iconPath: 'assets/icons/table-tennis.png',
  ),
  SportItem(
    type: SportType.basketball,
    title: 'كرة سلة',
    iconPath: 'assets/icons/Basketball.png',
  ),
  SportItem(
    type: SportType.padel,
    title: 'بادل',
    iconPath: 'assets/icons/Padel.png',
  ),
  SportItem(
    type: SportType.pool,
    title: 'بلياردو',
    iconPath: 'assets/icons/pool-table.png',
  ),
  SportItem(
    type: SportType.swimming,
    title: 'سباحة',
    iconPath: 'assets/icons/swimming.png',
  ),
  SportItem(
    type: SportType.pc,
    title: 'PC',
    iconPath: 'assets/icons/pc.png',
  ),
  SportItem(
    type: SportType.ps,
    title: 'PS4/PS5',
    iconPath: 'assets/icons/ps.png',
  ),
];

