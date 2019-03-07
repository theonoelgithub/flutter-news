import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';


class StoriesBloc {
  final _topIds = PublishSubject<List<int>>(); //stream controller in RXdart
  final _repository = Repository();

  //getters to streams
  Observable<List<int>> get topIds => _topIds.stream;

  fetchTopIds() async {
    final ids = await _repository.fetchTopIds();
    _topIds.sink.add(ids);
  }

  dispose() {
    _topIds.close();
  }
}