import 'package:flutter/material.dart';

/// RouteObserver global pour être notifié quand une page revient au premier plan.
///
/// À brancher dans MaterialApp.navigatorObservers.
final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

