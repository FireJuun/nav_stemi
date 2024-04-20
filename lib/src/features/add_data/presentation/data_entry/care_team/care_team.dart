import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/presentation/data_entry/care_team/care_team_header.dart';
import 'package:random_name_generator/random_name_generator.dart';

/// spec: https://api.flutter.dev/flutter/widgets/SliverAnimatedList-class.html#widgets.SliverAnimatedList.1
class CareTeam extends StatefulWidget {
  const CareTeam({super.key});

  @override
  State<CareTeam> createState() => _CareTeamState();
}

class _CareTeamState extends State<CareTeam> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  late ListModel<String> _list;
  String? _selectedItem;
  final generator = RandomNames(Zone.us);
  late final initialItems = <String>[
    generator.fullName(),
    generator.fullName(),
    generator.fullName(),
  ];

  @override
  void initState() {
    super.initState();
    _list = ListModel<String>(
      listKey: _listKey,
      initialItems: initialItems,
      removedItemBuilder: _buildRemovedItem,
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    return CareTeamMember(
      fullName: _list[index],
      animation: animation,
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  /// The builder function used to build items that have been removed.
  ///
  /// Used to build an item after it has been removed from the list. This method
  /// is needed because a removed item remains visible until its animation has
  /// completed (even though it's gone as far this ListModel is concerned). The
  /// widget will be used by the [AnimatedListState.removeItem] method's
  /// [AnimatedRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
    String item,
    BuildContext context,
    Animation<double> animation,
  ) {
    return CareTeamMember(
      animation: animation,
      fullName: item,
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    final index =
        _selectedItem == null ? _list.length : _list.indexOf(_selectedItem!);
    _list.insert(index, generator.fullName());
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem!));
      setState(() {
        _selectedItem = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select an item to remove from the list.',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO(FireJuun): update UI to match design
    return SliverMainAxisGroup(
      slivers: [
        CareTeamHeader(
          ' '.hardcoded,
          trailing: Row(
            children: [
              IconButton(
                onPressed: _insert,
                tooltip: 'Add Care Team Member'.hardcoded,
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: _remove,
                tooltip: 'Remove Care Team Member'.hardcoded,
                icon: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        SliverAnimatedList(
          key: _listKey,
          initialItemCount: _list.length,
          itemBuilder: _buildItem,
        ),
      ],
    );
  }
}

class CareTeamMember extends StatelessWidget {
  const CareTeamMember({
    required this.fullName,
    required this.animation,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String fullName;
  final bool selected;
  final VoidCallback? onTap;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedTileColor: colorScheme.secondaryContainer,
      title: Text(fullName),
      trailing: IconButton(
        icon: const Icon(Icons.info),
        onPressed: () {
          // TODO(FireJuun): Additional info about a care team member
        },
      ),
    );
  }
}

typedef RemovedItemBuilder<E> = Widget Function(
  E item,
  BuildContext context,
  Animation<double> animation,
);

// Keeps a Dart [List] in sync with an [AnimatedList].
//
// The [insert] and [removeAt] methods apply to both the internal list and
// the animated list that belongs to [listKey].
//
// This class only exposes as much of the Dart List API as is needed by the
// sample app. More list methods are easily added, however methods that
// mutate the list must make the same changes to the animated list in terms
// of [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  SliverAnimatedListState get _animatedList => listKey.currentState!;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
        (BuildContext context, Animation<double> animation) =>
            removedItemBuilder(removedItem, context, animation),
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
