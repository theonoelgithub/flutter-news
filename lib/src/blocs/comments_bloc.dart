import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';

class CommentsBloc {
  // 2 stream controllers to avoid overfetching because of the streambuilders in the widget
  // this avoids the stream builders to call each time the transformer which is called only once.
  final _commentsFetcher = PublishSubject<int>(); // 1st Stream Controller 
  final _commentsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>(); // 2nd Stream controller handling the cache map
  final _repository = Repository();

  // getters to stream from CommentsOutput
  Observable<Map<int, Future<ItemModel>>> get itemWithComments =>
    _commentsOutput.stream;

  // getters to sinks from CommentsFetcher
  Function(int) get fetchItemWithComments => _commentsFetcher.sink.add;

  // CommentsBloc constructor to get CommentsFetcher stream, transform it with commentsTransformer
  // then send it to commentsOutput which is used by the stream builders
  CommentsBloc() {
    _commentsFetcher.stream
      .transform(_commentsTransformer())
        .pipe(_commentsOutput);
  }

  _commentsTransformer() {
    return ScanStreamTransformer<int, Map<int, Future<ItemModel>>>(
      (cache, int id, index) {
        cache[id] = _repository.fetchItem(id);
        cache[id].then((ItemModel item) {
          item.kids.forEach((kidId) => fetchItemWithComments(kidId)); // recursive fetching
        });
        return cache;
      },
      <int, Future<ItemModel>>{},
    );
  }

  dispose() {
    _commentsFetcher.close();
    _commentsOutput.close();
  }
}