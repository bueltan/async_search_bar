library async_search_bar;

import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'search_bar_style.dart';

mixin ControllerListener<T> on State<SearchBar<T>> {
  void onListChanged(List<T> items) {}

  void onLoading() {}

  void onClear() {}

  void onError(Error error) {}

  void onSummit() {}

  void onTap() {}

}

class SearchBarController<T> {
  final List<T> _list = [];
  final List<T> _filteredList = [];
  final List<T> _sortedList = [];
  TextEditingController? _searchQueryController;
  String? _lastSearchedText;
  Future<List<T>> Function(String text)? _lastSearchFunction;
  ControllerListener? _controllerListener;
  int Function(T a, T b)? _lastSorting;
  CancelableOperation? _cancelableOperation;
  int minimumChars = 1;

  void setTextController(
      TextEditingController searchQueryController, minimunChars) {
    searchQueryController = searchQueryController;
    minimumChars = minimunChars;
  }

  void setListener(ControllerListener controllerListener) {
    _controllerListener = controllerListener;
  }

  void clear() {
    _controllerListener?.onClear();
  }

  void _search(
      String text, Future<List<T>> Function(String text) onSearch) async {
    _controllerListener?.onLoading();
    try {
      if (_cancelableOperation != null) {
        if (!_cancelableOperation!.isCompleted ||
            !_cancelableOperation!.isCanceled) {
          _cancelableOperation!.cancel();
        }
      }

      _cancelableOperation = CancelableOperation.fromFuture(
        onSearch(text),
        onCancel: () => {},
      );

      final List<T> items = await _cancelableOperation!.value;
      _lastSearchFunction = onSearch;
      _lastSearchedText = text;
      _list.clear();
      _filteredList.clear();
      _sortedList.clear();
      _lastSorting = null;
      _list.addAll(items);
      _controllerListener?.onListChanged(_list);
    } on Error catch (error) {
      _controllerListener?.onError(error);
    }
  }

  void injectSearch(
      String? searchText, Future<List<T>> Function(String text) onSearch) {
    if (searchText != null && searchText.length >= minimumChars) {
      _searchQueryController?.text = searchText;
      _search(searchText, onSearch);
    }
  }

  void replayLastSearch() {
    if (_lastSearchFunction != null && _lastSearchedText != null) {
      _search(_lastSearchedText!, _lastSearchFunction!);
    }
  }

  void removeFilter() {
    _filteredList.clear();
    if (_lastSorting == null) {
      _controllerListener?.onListChanged(_list);
    } else {
      _sortedList.clear();
      _sortedList.addAll(List<T>.from(_list));
      _sortedList.sort(_lastSorting);
      _controllerListener?.onListChanged(_sortedList);
    }
  }

  void removeSort() {
    _sortedList.clear();
    _lastSorting = null;
    _controllerListener
        ?.onListChanged(_filteredList.isEmpty ? _list : _filteredList);
  }

  void sortList(int Function(T a, T b) sorting) {
    _lastSorting = sorting;
    _sortedList.clear();
    _sortedList
        .addAll(List<T>.from(_filteredList.isEmpty ? _list : _filteredList));
    _sortedList.sort(sorting);
    _controllerListener?.onListChanged(_sortedList);
  }

  void filterList(bool Function(T item) filter) {
    _filteredList.clear();
    _filteredList.addAll(_sortedList.isEmpty
        ? _list.where(filter).toList()
        : _sortedList.where(filter).toList());
    _controllerListener?.onListChanged(_filteredList);
  }
}

class SearchBar<T> extends StatefulWidget {
  /// Future returning searched items
  final Future<List<T>> Function(String text) onSearch;
  final void Function()? onSummit;
  final void Function()? onTap;
  final FocusNode? focusNode;

  final TextEditingController? textEditingController;
  /// default false.
  final bool autoFocus;

  /// List of items showed by default
  final List<T> suggestions;

  /// Callback returning the widget corresponding to a Suggestion item
  final Widget Function(T item, int index)? buildSuggestion;

  /// Minimum number of chars required for a search
  final int minimumChars;

  /// Callback returning the widget corresponding to an item found
  final Widget Function(T item, int index) onItemFound;

  /// Callback returning the widget corresponding to an Error while searching
  final Widget Function(Error error)? onError;

  /// Cooldown between each call to avoid too many
  final Duration debounceDuration;

  /// Widget to show when loading
  final Widget loader;

  /// Widget to show when no item were found
  final Widget emptyWidget;

  /// Widget to show by default
  final Widget? placeHolder;

  /// Widget showed on left of the search bar
  final Widget? icon;

  /// Widget placed between the search bar and the results
  final Widget? header;

  /// Hint text of the search bar
  final String hintText;

  /// TextStyle of the hint text
  final TextStyle hintStyle;

  /// Color of the icon when search bar is active
  final Color iconActiveColor;

  /// Text style of the text in the search bar
  final TextStyle textStyle;

  /// Widget shown for cancellation
  final Widget cancellationWidget;

  /// Callback when cancel button is triggered
  final VoidCallback? onCancelled;

  /// Controller used to be able to sort, filter or replay the search
  final SearchBarController? searchBarController;

  /// Enable to edit the style of the search bar
  final SearchBarStyle searchBarStyle;

  /// Number of items displayed on cross axis
  final int crossAxisCount;

  /// Weather the list should take the minimum place or not
  final bool shrinkWrap;

  /// Set the scrollDirection
  final Axis scrollDirection;

  /// Spacing between tiles on main axis
  final double mainAxisSpacing;

  /// Spacing between tiles on cross axis
  final double crossAxisSpacing;

  /// Set a padding on the search bar
  final EdgeInsetsGeometry searchBarPadding;

  /// Set a padding on the header
  final EdgeInsetsGeometry headerPadding;

  /// Set a padding on the list
  final EdgeInsetsGeometry listPadding;

  const SearchBar({
    super.key,
    this.autoFocus = false,
    required this.onSearch,
    required this.onItemFound,
    this.searchBarController,
    this.minimumChars = 3,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.loader = const Center(child: CircularProgressIndicator()),
    this.onError,
    this.emptyWidget = const SizedBox.shrink(),
    this.header,
    this.placeHolder,
    this.icon = const Icon(Icons.search),
    this.hintText = "",
    this.hintStyle = const TextStyle(color: Color.fromRGBO(142, 142, 147, 1)),
    this.iconActiveColor = Colors.black,
    this.textStyle = const TextStyle(color: Colors.black),
    this.cancellationWidget = const Text("Cancel"),
    this.onCancelled,
    this.onSummit,
    this.onTap,
    this.textEditingController,
    this.focusNode,
    this.suggestions = const [],
    this.buildSuggestion,
    this.searchBarStyle = const SearchBarStyle(),
    this.crossAxisCount = 1,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.listPadding = const EdgeInsets.all(0),
    this.searchBarPadding = const EdgeInsets.all(0),
    this.headerPadding = const EdgeInsets.all(0),
  });

  @override
  SearchBarState createState() => SearchBarState<T>();
}

class SearchBarState<T> extends State<SearchBar<T>>
    with TickerProviderStateMixin, ControllerListener<T> {
  bool _loading = false;
  Widget? _error;
  late final _searchQueryController ;

  Timer? _debounce;
  bool _animate = false;
  List<T> _list = [];
  SearchBarController? searchBarController;

  @override
  void initState() {
    super.initState();
    if (widget.textEditingController != null) {
      _searchQueryController = widget.textEditingController!;
    } else {
      _searchQueryController = TextEditingController();
    }
    searchBarController ??= SearchBarController<T>();
    searchBarController?.setListener(this);
    searchBarController?.setTextController(
        _searchQueryController, widget.minimumChars);
  }

  @override
  void onListChanged(List<T> items) {
    setState(() {
      _loading = false;
      _list = items;
    });
  }

  @override
  void onLoading() {
    setState(() {
      _loading = true;
      _error = null;
      _animate = true;
    });
  }

  @override
  void onSummit() {
    print("on summit");
    widget.onSummit!();
  }
  
  @override
  void onTap() {
    print("on tap");
    widget.onTap!();
  }
  @override
  void onClear() {
    _cancel();
  }

  @override
  void onError(Error error) {
    setState(() {
      _loading = false;
      _error =
          widget.onError != null ? widget.onError!(error) : const Text("error");
    });
  }

  _onTextChanged(String newText) async {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(widget.debounceDuration, () async {
      if (newText.length >= widget.minimumChars) {
        searchBarController?._search(newText, widget.onSearch);
      } else {
        setState(() {
          _list.clear();
          _error = null;
          _loading = false;
          _animate = false;
        });
      }
    });
  }

  void _cancel() {
    if (widget.onCancelled != null) {
      widget.onCancelled!();
    }

    setState(() {
      _searchQueryController.clear();
      _list.clear();
      _error = null;
      _loading = false;
      _animate = false;
    });
  }

  Widget _buildListView(
      List<T> items, Widget Function(T item, int index) builder) {
    return Padding(
      padding: widget.listPadding,
      child: MasonryGridView.count(
        itemCount: items.length,
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        shrinkWrap: widget.shrinkWrap,
        scrollDirection: widget.scrollDirection,
        itemBuilder: (BuildContext context, int index) {
          return builder(items[index], index);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return _error!;
    } else if (_loading) {
      return widget.loader;
    } else if (_searchQueryController.text.length < widget.minimumChars) {
      if (widget.placeHolder != null) return widget.placeHolder!;
      return _buildListView(
          widget.suggestions, widget.buildSuggestion ?? widget.onItemFound);
    } else if (_list.isNotEmpty) {
      return _buildListView(_list, widget.onItemFound);
    } else {
      return widget.emptyWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthMax = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: widget.searchBarPadding,
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _animate ? widthMax * .8 : widthMax,
                    decoration: BoxDecoration(
                      borderRadius: widget.searchBarStyle.borderRadius,
                      color: widget.searchBarStyle.backgroundColor,
                    ),
                    child: Padding(
                      padding: widget.searchBarStyle.padding,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: widget.iconActiveColor,
                        ),
                        child: TextField(
                          onTap: onTap,
                          textInputAction: TextInputAction.search,
                          onEditingComplete: onSummit,
                          autofocus: widget.autoFocus,
                          focusNode: widget.focusNode,
                          controller: _searchQueryController,
                          onChanged: _onTextChanged,
                          style: widget.textStyle,
                          cursorColor: widget.searchBarStyle.cursorColor,
                          
                          decoration: InputDecoration(
                            icon: widget.icon,
                            border: InputBorder.none,
                            hintText: widget.hintText,
                            hintStyle: widget.hintStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _cancel,
                  child: AnimatedOpacity(
                    opacity: _animate ? 1.0 : 0,
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: _animate ? 1000 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width:
                          _animate ? MediaQuery.of(context).size.width * .2 : 0,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: widget.cancellationWidget,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: widget.headerPadding,
          child: widget.header ?? Container(),
        ),
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }
}
