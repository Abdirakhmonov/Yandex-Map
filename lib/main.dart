import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_map/restoran_yandex/bloc/map_cubit.dart';
import 'package:yandex_map/restoran_yandex/ui/home_screen.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => MapCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: MapScreen(),
        ));
  }
}
