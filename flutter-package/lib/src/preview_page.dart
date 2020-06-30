import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preview/preview.dart';
import 'package:window_size/window_size.dart';

class PreviewPage extends StatelessWidget {
  final List<Previewer> Function() providers;
  final String path;
  final Widget child;

  const PreviewPage({
    Key key,
    List<Previewer> Function() providers,
    this.child,
    this.path,
  })  : this.providers = providers,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = providers?.call() ?? const <Previewer>[];
    print('page_${path}_${list.length}');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: _ProviderPageView(
        key: Key('page_${path}_${list.length}'),
        providers: list,
        child: child,
        path: path,
      ),
    );
  }
}

class _ProviderPageView extends StatefulWidget {
  final List<Previewer> providers;
  final Widget child;
  final String path;

  const _ProviderPageView({
    Key key,
    this.providers,
    this.child,
    this.path,
  }) : super(key: key);

  @override
  _ProviderPageViewState createState() => _ProviderPageViewState();
}

class _ProviderPageViewState extends State<_ProviderPageView>
    with TickerProviderStateMixin {
  TabController tabController;


  @override
  void initState() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (details.exceptionAsString() ==
          'Unimplemented handling of missing static target')
        return Container(
            color: Colors.black,
            padding: EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  child: IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: () async {
                        Timeline.timeSync("Doing Something", () {
                          postEvent('Preview.hotRestart', <String, String>{});
                        });
                        /*  final client = HttpClient();
                        final request = await client.getUrl(Uri.parse(
                            'https://127.0.0.1:808/&hotrestart=true'));
                        final response = await request.close();
                        print(response); */
                      }),
                ),
                Text(
                  'An error occurred while\nperforming hot reload',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                SizedBox(height: 4),
                Flexible(
                  child: Text(
                    'Unimplemented handling of missing static target',
                    style: TextStyle(color: Colors.white38),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                SizedBox(height: 20),
                Flexible(
                  child: Text(
                    'Use hot restart to solve the problem',
                    style: TextStyle(color: Colors.white),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ));
      String message = '';
      assert(() {
        message = _stringify(details.exception) +
            '\nSee also: https://flutter.dev/docs/testing/errors';
        return true;
      }());
      final Object exception = details.exception;
      return ErrorWidget.withDetails(
          message: message,
          error: exception is FlutterError ? exception : null);
    };
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString() ==
          'Unimplemented handling of missing static target') {
        //WidgetsBinding.instance.reassembleApplication();
        /*  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          WidgetsBinding.instance.reassembleApplication();
        }); */
      }
      FlutterError.presentError(details);
    };
    tabController = TabController(
        initialIndex: 0, length: widget.providers.length, vsync: this);
    tabController.addListener(update);
    if (widget.path == null)
      setWindowTitle('Preview');
    else
      setWindowTitle('Preview - ${widget.path}');
    super.initState();
  }

  update() => setState(() => {print('update')});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: widget.providers.length <= 1
          ? null
          : PreferredSize(
              child: Container(
                color: Colors.grey[800],
                child: TabBar(
                  indicator: BoxDecoration(),
                  indicatorWeight: 0,
                  labelPadding: EdgeInsets.all(0),
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: true,
                  tabs: List.generate(
                    widget.providers.length,
                    (index) => Tab(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        color:
                            tabController.index == index ? Colors.black : null,
                        child: Text(
                            '${widget.providers[index].runtimeType.toString()}',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              preferredSize: Size(double.infinity, 36),
            ),
      bottomNavigationBar: widget.providers.length <= 1
              ? null
              : Container(
                  height: 22,
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: tabController.index == 0 ? 0 : 1,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            child: Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_left,
                                size: 20,
                              ),
                            )),
                            onTap: tabController.index == 0
                                ? null
                                : () => tabController.animateTo(
                                    tabController.index,
                                    duration: Duration(milliseconds: 700),
                                    curve: Curves.easeInOut),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${tabController.index + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            ' / ',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          Text(
                            '${widget.providers.length}',
                            style: TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.w300,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: tabController.index == (widget.providers.length - 1)
                            ? 0
                            : 1,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            child: Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_right,
                                size: 20,
                              ),
                            )),
                            onTap: () =>
                                tabController.index == tabController.length - 1
                                    ? null
                                    : tabController.animateTo(
                                        tabController.index + 1,
                                        duration: Duration(milliseconds: 700),
                                        curve: Curves.easeInOut),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      body: widget.child != null
          ? Center(child: widget.child)
          : TabBarView(
              controller: tabController,
              children: widget.providers
                  .map(
                    (e) => e,
                  )
                  .toList(),
            ),
    );
  }

  @override
  void dispose() {
    tabController.removeListener(update);
    tabController.dispose();
    super.dispose();
  }
}

class WidgetProvider extends StatelessWidget {
  final Previewer previewer;

  const WidgetProvider({Key key, this.previewer}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return previewer.build(context);
  }
}

String _stringify(Object exception) {
  try {
    return exception.toString();
  } catch (e) {
    // intentionally left empty.
  }
  return 'Error';
}
