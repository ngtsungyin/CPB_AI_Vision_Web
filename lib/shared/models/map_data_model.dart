import 'package:flutter/material.dart';

class MapDataModel {
  final String statename;
  final int farmers;
  final int scans;
  final double yieldRevenue;
  final Color color;

  MapDataModel({
    required this.statename,
    required this.farmers,
    required this.scans,
    required this.yieldRevenue,
    required this.color,
  });
}