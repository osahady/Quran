import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:quran_reader/common/constant/constants.dart' as constants;
import 'package:quran_reader/common/database/database.dart';
import 'package:quran_reader/feature/quran_page/bloc/blocs.dart';
import 'package:quran_reader/feature/quran_page/model/models.dart';
import 'package:rxdart/rxdart.dart';

class QuranPageBloc extends HydratedBloc<QuranPageEvent, QuranPageState> {
  final AyahInfoService ayahInfoService;

  QuranPageBloc({@required this.ayahInfoService})
      : assert(ayahInfoService != null);

  @override
  QuranPageState get initialState {
    return super.initialState ??
        QuranPageJumpedTo(
            quranPage: fetchQuranPage(constants.start_quran_page_number));
  }

  @override
  QuranPageState fromJson(Map<String, dynamic> json) {
    try {
      final quranPage =
          QuranPage.fromJson(Map<String, dynamic>.from(json['value']));
      return QuranPageJumpedTo(quranPage: quranPage);
    } catch (exception) {
      return null;
    }
  }

  @override
  Stream<Transition<QuranPageEvent, QuranPageState>> transformEvents(
    Stream<QuranPageEvent> events,
    TransitionFunction<QuranPageEvent, QuranPageState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 2)),
      transitionFn,
    );
  }

  @override
  Stream<QuranPageState> mapEventToState(QuranPageEvent event) async* {
    if (event is JumpToPage) {
      yield* _mapJumpToPage(event);
    }

    if (event is LoadPage) {
      yield* _mapLoadPage(event);
    }
  }

  @override
  Map<String, Map<String, dynamic>> toJson(QuranPageState state) {
    try {
      if (state is QuranPageLoaded) {
        return {'value': state.quranPage.toJson()};
      }
      if (state is QuranPageJumpedTo) {
        return {'value': state.quranPage.toJson()};
      } else {
        return null;
      }
    } catch (exception) {
      return null;
    }
  }

  Stream<QuranPageState> _mapJumpToPage(JumpToPage event) async* {
    final _quranPage = fetchQuranPage(event.pageNumber);
    _quranPage.quranPageInfoList =
        await ayahInfoService.getQuranPageInfo(pageNumber: _quranPage.page);
    yield QuranPageJumpedTo(quranPage: _quranPage);
  }

  Stream<QuranPageState> _mapLoadPage(LoadPage event) async* {
    final _quranPage = fetchQuranPage(event.pageNumber);
    _quranPage.quranPageInfoList =
        await ayahInfoService.getQuranPageInfo(pageNumber: _quranPage.page);
    yield QuranPageLoaded(quranPage: _quranPage);
  }

  QuranPage fetchQuranPage(int page) {
    return QuranPage(
        page: page, imageUrl: 'assets/images/quran/image$page.png');
  }
}
