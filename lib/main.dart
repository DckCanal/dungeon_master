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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  addChar(CombatPlayingCharacter char) {
    chars.add(char);
    notifyListeners();
  }

  removeChar(CombatPlayingCharacter char) {
    if (chars.contains(char)) {
      chars.remove(char);
      notifyListeners();
    }
  }

  sortChars() {
    chars.sort((a, b) => b.initiativeRoll - a.initiativeRoll);
    notifyListeners();
  }

  moveForward(CombatPlayingCharacter char) {
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

  moveBackward(CombatPlayingCharacter char) {
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
  var currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var chars = appState.chars;

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
          child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 200 / 100,
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
                              children: [
                                Text(char.name, style: nameStyle),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
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
                              children: [
                                const Icon(Icons.flash_on_sharp, size: 20),
                                Text('${char.initiativeRoll}',
                                    style: initiativeStyle),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.arrow_left_outlined,
                                      semanticLabel: 'Delay initiative'),
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    appState.moveBackward(char);
                                  },
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.arrow_right_outlined,
                                      semanticLabel: 'Delay initiative'),
                                  color: theme.colorScheme.primary,
                                  onPressed: () {
                                    appState.moveForward(char);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
              ]),
        ),
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  appState.addChar(CombatPlayingCharacter(20, 'Malakay', 12));
                  appState.addChar(CombatPlayingCharacter(12, 'Melkor', 8));
                  appState
                      .addChar(CombatPlayingCharacter(34, 'Bandito capo', 15));
                },
                child: const Text('Add')),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_right_alt_rounded),
              label: const Text('Avanti'),
              onPressed: () {
                if (currentIndex == chars.length - 1) {
                  setState(() {
                    currentIndex = 0;
                  });
                } else {
                  setState(() {
                    currentIndex++;
                  });
                }
              },
            )
          ],
        ),
      ],
    );
  }
}
