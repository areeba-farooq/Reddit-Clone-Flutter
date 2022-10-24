import 'package:flutter/material.dart';
import 'package:reddit_clone/Features/Auth/Screens/login_screen.dart';
import 'package:reddit_clone/Features/Community/screens/community_screen.dart';
import 'package:reddit_clone/Features/Home/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: LoginScreen(),
        ),
  },
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: HomeScreen(),
        ),
    '/create-community': (_) => const MaterialPage(
          child: CreateCommunityScreen(),
        ),
  },
);
