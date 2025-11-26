// models/map_data_model.dart
import 'package:flutter/material.dart';

class MapDataModel {
  final String statename;
  final int farmers;
  final int scans;
  final int sprays;
  final Color color;

  MapDataModel({
    required this.statename,
    required this.farmers,
    required this.scans,
    required this.sprays,
    required this.color,
  });
}