import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seven_spot_mobile/common/TextStyles.dart';
import 'package:seven_spot_mobile/interactors/FiringListInteractor.dart';
import 'package:seven_spot_mobile/pages/FiringsList.dart';
import 'package:seven_spot_mobile/pages/ManageFiringPage.dart';
import 'package:seven_spot_mobile/pages/ManageOpeningPage.dart';
import 'package:seven_spot_mobile/pages/OpeningsList.dart';
import 'package:seven_spot_mobile/pages/RegisterAsAdminPage.dart';
import 'package:seven_spot_mobile/services/AuthService.dart';
import 'package:seven_spot_mobile/usecases/DeleteUserUseCase.dart';
import 'package:seven_spot_mobile/usecases/GetAllOpeningsUseCase.dart';
import 'package:seven_spot_mobile/usecases/GetUserUseCase.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, _getUser);
  }

  _getUser() async {
    try {
      await Provider.of<GetUserUseCase>(context, listen: false).getUser();
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("An error occurred while fetching your details."),
              actions: [
                FlatButton(
                  child: Text("Sign out"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<AuthService>(context, listen: false)
                        .signOutOfGoogle();
                  },
                ),
                FlatButton(
                  child: Text("Retry"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getUser();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
        appBar: AppBar(title: Consumer<GetUserUseCase>(
          builder: (context, useCase, child) {
            return Text(useCase.user?.studioName ?? "Loading...");
          },
        )),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/ic_launcher.png"),
                        width: 32,
                        color: Colors.black),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text("Pottery studio",
                          style: TextStyles().bigRegularStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Consumer<GetUserUseCase>(
                        builder: (context, useCase, _) {
                          return Text(
                              "${useCase.user?.name ?? "Loading..."} ${useCase.user?.isAdmin == true ? "(admin)" : ""}",
                              style: TextStyles().mediumRegularStyle);
                        },
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.black),
                  title: Text("Sign out"),
                  onTap: authService.signOutOfGoogle),
              ListTile(
                  leading: Icon(Icons.delete, color: Colors.black),
                  title: Text("Delete my account"),
                  onTap: () async {
                    Navigator.of(context).pop();

                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Delete account"),
                            content: Text(
                                "Deleting your account will remove you from all reservations."),
                            actions: [
                              FlatButton(
                                child: Text("Cancel"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              FlatButton(
                                color: Colors.red,
                                child: Text("Delete"),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  var success =
                                      await Provider.of<DeleteUserUseCase>(
                                              context,
                                              listen: false)
                                          .invoke();

                                  if (success) {
                                    authService.signOutOfGoogle();
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Error"),
                                            content: Text(
                                                "An error occurred while deleting your account. Please contact the developer."),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text("Dismiss"),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                },
                              )
                            ],
                          );
                        });
                  }),
              ListTile(
                  leading: Icon(Icons.person, color: Colors.black),
                  title: Text("Register as admin"),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterAsAdminPage()))),
              Consumer<GetUserUseCase>(builder: (context, getUserUseCase, _) {
                return Visibility(
                  visible: getUserUseCase.user?.isAdmin ?? false,
                  child: ListTile(
                      leading: Icon(Icons.home, color: Colors.black),
                      title: Text(
                          "Studio code: ${getUserUseCase.user?.studioCode} (tap to copy)"),
                      onTap: () async {
                        Navigator.of(context).pop();

                        await Clipboard.setData(ClipboardData(
                            text: getUserUseCase.user?.studioCode));

                        final snackBar =
                            SnackBar(content: Text('Copied to Clipboard'));

                        Scaffold.of(context).showSnackBar(snackBar);
                      }),
                );
              }),
              Consumer<GetUserUseCase>(builder: (context, getUserUseCase, _) {
                return Visibility(
                  visible: getUserUseCase.user?.isAdmin ?? false,
                  child: ListTile(
                      leading: Icon(Icons.book, color: Colors.black),
                      title: Text(
                          "Admin code: ${getUserUseCase.user?.studioAdminCode} (tap to copy)"),
                      onTap: () async {
                        Navigator.of(context).pop();

                        await Clipboard.setData(ClipboardData(
                            text: getUserUseCase.user?.studioAdminCode));

                        final snackBar =
                            SnackBar(content: Text('Copied to Clipboard'));

                        Scaffold.of(context).showSnackBar(snackBar);
                      }),
                );
              })
            ],
          ),
        ),
        bottomNavigationBar: _bottomNavBar(),
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            Consumer<GetAllOpeningsUseCase>(builder: (context, useCase, _) {
              return OpeningsList(
                  openings: useCase.openings,
                  onRefresh:
                      Provider.of<GetAllOpeningsUseCase>(context, listen: false)
                          .invoke);
            }),
            FiringsList()
          ],
        ),
        floatingActionButton:
            Consumer<GetUserUseCase>(builder: (context, useCase, _) {
          return Visibility(
            visible: useCase.user?.isAdmin ?? false,
            child: FloatingActionButton.extended(
              onPressed: _onFabPressed,
              icon: Icon(Icons.add),
              label: Text("Add ${_currentIndex == 0 ? "Opening" : "Firing"}"),
            ),
          );
        }));
  }

  void _onFabPressed() async {
    if (_currentIndex == 0) {
      var shouldRefreshList = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => ManageOpeningPage()));

      if (shouldRefreshList ?? false)
        Provider.of<GetAllOpeningsUseCase>(context, listen: false).invoke();
    } else {
      var shouldRefreshList = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ManageFiringPage()));

      if (shouldRefreshList ?? false)
        Provider.of<FiringListInteractor>(context, listen: false).getAll();
    }
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              title: Text("Openings"), icon: Icon(Icons.event_available)),
          BottomNavigationBarItem(
              title: Text("Firings"), icon: Icon(Icons.whatshot))
        ],
        currentIndex: _currentIndex,
        onTap: (idx) {
          // todo: move to interactor: ChangeNotifier
          setState(() {
            _currentIndex = idx;
          });
        },
        selectedItemColor: Colors.lightBlue);
  }
}
