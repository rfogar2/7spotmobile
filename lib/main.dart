import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seven_spot_mobile/interactors/FiringListInteractor.dart';
import 'package:seven_spot_mobile/pages/CreateUserPage.dart';
import 'package:seven_spot_mobile/pages/LoginPage.dart';
import 'package:seven_spot_mobile/pages/MainPage.dart';
import 'package:seven_spot_mobile/repositories/FiringRepository.dart';
import 'package:seven_spot_mobile/repositories/OpeningRepository.dart';
import 'package:seven_spot_mobile/repositories/UserRepository.dart';
import 'package:seven_spot_mobile/services/AuthService.dart';
import 'package:seven_spot_mobile/services/FiringService.dart';
import 'package:seven_spot_mobile/usecases/CreateUserUseCase.dart';
import 'package:seven_spot_mobile/usecases/DeleteOpeningUseCase.dart';
import 'package:seven_spot_mobile/usecases/GetAllFiringsUseCase.dart';
import 'package:seven_spot_mobile/usecases/GetOpeningUseCase.dart';
import 'package:seven_spot_mobile/usecases/GetUserUseCase.dart';
import 'package:seven_spot_mobile/usecases/ManageOpeningUseCase.dart';
import 'package:seven_spot_mobile/usecases/ToggleReservationUseCase.dart';

void main() async {
  var authService = AuthService();
  var createUserUseCase = CreateUserUseCase(authService);
  var openingRepository = OpeningRepository();
  var userRepository = UserRepository();
  var toggleReservationUseCase = ToggleReservationUseCaseImpl(openingRepository);
  var getUserUseCase = GetUserUseCaseImpl(userRepository);
  var getOpeningUseCase = GetOpeningUseCase(openingRepository);
  var manageOpeningUseCase = ManageOpeningUseCase(openingRepository);
  var deleteOpeningUseCase = DeleteOpeningUseCase(openingRepository);
  var firingService = FiringService();
  var firingRepository = FiringRepository(firingService);
  var getAllFiringsUseCase = GetAllFiringsUseCase(firingRepository);
  var firingListInteractor = FiringListInteractor(getAllFiringsUseCase);

  return await runZoned<Future<Null>>(
    () async {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => authService,
            ),
            Provider<CreateUserUseCase>(
              create: (_) => createUserUseCase,
            ),
            ChangeNotifierProvider<ToggleReservationUseCase>(
              create: (_) => toggleReservationUseCase
            ),
            ChangeNotifierProvider<GetUserUseCase>(
              create: (_) => getUserUseCase
            ),
            ChangeNotifierProvider<GetOpeningUseCase>(
              create: (_) => getOpeningUseCase,
            ),
            ChangeNotifierProvider<ManageOpeningUseCase>(
              create: (_) => manageOpeningUseCase,
            ),
            ChangeNotifierProvider<DeleteOpeningUseCase>(
              create: (_) => deleteOpeningUseCase,
            ),
            ChangeNotifierProvider<FiringListInteractor>(
              create: (_) => firingListInteractor,
            )
          ],
          child: MyApp()
        ),
      );
    }
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<AuthService>(
        builder: (context, auth, child) {
          switch(auth.state) {
            case AppState.VALIDATED:
              return MainPage();
            case AppState.AUTHENTICATED:
              return CreateUserPage();
            default:
              return LoginPage();
          }
        },
      )
    );
  }
}
