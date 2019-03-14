import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';
import 'dart:async';


class StoriesBloc {
  // 2 stream controllers to avoid overfetching because of the streambuilders in the widget
  // this avoids the stream builders to call each time the transformer which is called only once.
  final _topIds = PublishSubject<List<int>>(); // Stream controller for the topIds.
  final _repository = Repository();
  final _itemsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>(); // 2nd stream controller
  final _itemsFetcher = PublishSubject<int>(); // 1st stream controller in RXdart

  //getters to streams
  Observable<List<int>> get topIds => _topIds.stream;
  Observable<Map<int, Future<ItemModel>>> get items => _itemsOutput.stream;
  
  // Getters to sinks
  Function(int) get fetchItem => _itemsFetcher.sink.add; // exposing the sink to the outside world

  // Constructor
  // Listen to the stream _itemsFetcher, then transform it as a cache map send to _itemsOutput stream used by the StreamBuilder in the widget NewsList
  StoriesBloc() {
    _itemsFetcher.stream.transform(_itemsTransformer()).pipe(_itemsOutput);
  }

  // Functions

  // 1st function called in NewsList widget to add the ids from the repository to the topIds streams, used by the StreamBuilder to build the widget list
  fetchTopIds() async {
    final ids = await _repository.fetchTopIds();
    _topIds.sink.add(ids);
  }

  // Clear Cache when refresh cf. NewsList widget & Refresh
  clearCache() {
    return _repository.clearCache();
  }

  // use ScanStreamTransformer to build & return a cache map for each id
  _itemsTransformer(){
    return ScanStreamTransformer(
      (Map<int, Future<ItemModel>> cache, int id, index) {
        cache[id] = _repository.fetchItem(id);
        return cache;
      },
      <int, Future<ItemModel>>{},
    );
  }

  dispose() {
    _topIds.close();
    _itemsFetcher.close();
    _itemsOutput.close();
  }
}