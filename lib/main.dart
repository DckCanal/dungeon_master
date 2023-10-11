import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Dungeon Master Pro',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class CombatPlayingCharacter {
  int hitPoints;
  final String name;
  int initiativeRoll;
  var status = <String>[];
  CombatPlayingCharacter(this.hitPoints, this.name, this.initiativeRoll);
}

class MyAppState extends ChangeNotifier {
  var chars = <CombatPlayingCharacter>[];
  int currentIndex = 0;
  int turnCounter = 1;

  void addChar(CombatPlayingCharacter char) {
    chars.add(char);
    notifyListeners();
  }

  void removeChar(CombatPlayingCharacter char) {
    if (chars.contains(char)) {
      if (chars.indexOf(char) < currentIndex) {
        currentIndex--;
      } else if (chars.indexOf(char) == chars.length - 1 &&
          chars.indexOf(char) == currentIndex) {
        currentIndex = 0;
        turnCounter++;
      }
      chars.remove(char);
      notifyListeners();
    }
  }

  void sortChars() {
    chars.sort((a, b) => b.initiativeRoll - a.initiativeRoll);
    notifyListeners();
  }

  void moveForward(CombatPlayingCharacter char) {
    if (chars.indexOf(char) == chars.length - 1) {
      chars.remove(char);
      chars.insert(0, char);
    } else {
      var index = chars.indexOf(char);
      chars.remove(char);
      chars.insert(index + 1, char);
    }
    notifyListeners();
  }

  void moveBackward(CombatPlayingCharacter char) {
    if (chars.indexOf(char) == 0) {
      chars.remove(char);
      chars.insert(chars.length, char);
    } else {
      var index = chars.indexOf(char);
      chars.remove(char);
      chars.insert(index - 1, char);
    }
    notifyListeners();
  }

  void nextRound() {
    if (currentIndex == chars.length - 1) {
      currentIndex = 0;
      turnCounter++;
    } else {
      currentIndex++;
    }
    notifyListeners();
  }

  CombatPlayingCharacter? getCurrentCharacter() {
    if (chars.isEmpty) return null;
    return chars[currentIndex];
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Placeholder();
        break;
      case 1:
        page = InitiativePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 900,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.flash_on_outlined),
                    label: Text('Initiative'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class InitiativePage extends StatefulWidget {
  @override
  State<InitiativePage> createState() => _InitiativePageState();
}

class _InitiativePageState extends State<InitiativePage> {
  // var currentIndex = 0;
  // int turnCounter = 1;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var chars = appState.chars;
    var currentIndex = appState.currentIndex;
    var turnCounter = appState.turnCounter;

    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
    );
    var nameStyle = theme.textTheme.bodyLarge;
    var hpStyle = theme.textTheme.headlineMedium;
    var initiativeStyle = theme.textTheme.bodyMedium;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Ordine di iniziativa',
              style: titleStyle.copyWith(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 330,
                  childAspectRatio: 200 / 120,
                ),
                children: [
                  for (CombatPlayingCharacter char in chars)
                    Card(
                        elevation:
                            chars.indexOf(char) == currentIndex ? 16.0 : 4.0,
                        color: chars.indexOf(char) == currentIndex
                            ? theme.colorScheme.secondaryContainer
                            : theme.colorScheme.surface,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(char.name, style: nameStyle),
                                  IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      appState.removeChar(char);
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '${char.hitPoints}',
                                  style: hpStyle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.flash_on_sharp,
                                            size: 20),
                                        Text('${char.initiativeRoll}',
                                            style: initiativeStyle),
                                      ]),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(
                                              Icons.arrow_left_outlined,
                                              semanticLabel:
                                                  'Anticipate initiative'),
                                          color: theme.colorScheme.primary,
                                          onPressed: () {
                                            appState.moveBackward(char);
                                          },
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(
                                              Icons.arrow_right_outlined,
                                              semanticLabel:
                                                  'Delay initiative'),
                                          color: theme.colorScheme.primary,
                                          onPressed: () {
                                            appState.moveForward(char);
                                          },
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                          ],
                        ))
                ]),
          ),
        ),
        Divider(
          indent: 15.0,
          endIndent: 15.0,
          height: 30,
          color: theme.colorScheme.primary,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: chars.isEmpty
                          ? []
                          : [
                              Text(chars[currentIndex].name),
                              Text('${chars[currentIndex].hitPoints}'),
                              Column(children: [
                                for (String s in chars[currentIndex].status)
                                  Text(s)
                              ]),
                            ],
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_right_alt_rounded),
                label: const Text('Avanti'),
                onPressed: () {
                  appState.nextRound();
                },
              ),
              const SizedBox(
                width: 18,
              ),
              FilledButton(
                  onPressed: () {
                    appState.addChar(CombatPlayingCharacter(20, 'Malakay', 12));
                    appState.addChar(CombatPlayingCharacter(12, 'Melkor', 8));
                    appState.addChar(
                        CombatPlayingCharacter(34, 'Bandito capo', 15));
                  },
                  child: const Text('Demo mass Add')),
              FilledButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Dialog(child: PlayingCharacterForm());
                        });
                  },
                  child: const Text('Add')),
            ],
          ),
        ),
      ],
    );
  }
}

class PlayingCharacterForm extends StatefulWidget {
  const PlayingCharacterForm({
    super.key,
    /*required this.onSubmit*/
  });
  //final void onSubmit;

  @override
  State<StatefulWidget> createState() {
    return _PlayingCharacterFormState();
  }
}

class _PlayingCharacterFormState extends State<PlayingCharacterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final hpController = TextEditingController();
  final initiativeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    hpController.dispose();
    initiativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 450,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: 300,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(hintText: 'Nome personaggio'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci un nome';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: hpController,
                      decoration:
                          const InputDecoration(hintText: 'Punti ferita'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci un numero valido';
                        } else {
                          try {
                            int.parse(value);
                          } catch (err) {
                            return 'Inserisci un numero valido';
                          }
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      controller: initiativeController,
                      decoration:
                          const InputDecoration(hintText: 'Tiro di iniziativa'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci un numero valido';
                        } else {
                          try {
                            int.parse(value);
                          } catch (err) {
                            return 'Inserisci un numero valido';
                          }
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final hp, init, name = nameController.text;
                        try {
                          hp = int.parse(hpController.text);
                          init = int.parse(initiativeController.text);
                          appState
                              .addChar(CombatPlayingCharacter(hp, name, init));
                        } catch (err) {
                          // Notify error with toast!
                        } finally {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('OK'),
                    )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
