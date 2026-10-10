import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/hotel_shell.dart';
import '../state/hotel_app_state.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HotelAppState()..load(),
      child: MaterialApp(
        title: 'StayBook',
        debugShowCheckedModeBanner: false,
        theme: buildAureaTheme(),
        home: const HotelShell(),
      ),
    );
  }
}
