import 'dart:convert';
import 'dart:math';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/infrastructure/db/app_database.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/logger.dart';
import 'package:ezscrip/util/search_option.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:sembast/sembast.dart';

class ConsultationRespository {
  static const String CONSULTATION_STORE_NAME = 'consultations';

  final StoreRef _consultationStore =
      intMapStoreFactory.store(CONSULTATION_STORE_NAME);

  Future<Database> getDb() async {
    return await GetIt.instance<AppDatabase>().database;
  }

  Future<int> insert(Consultation consultation) async {
    Logger.info("Adding Consultation");

    int id = await _consultationStore.add((await getDb()), consultation.toMap())
        as int;
    consultation.id = id;

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(consultation.toMap());

    Logger.info(
        "Added Consultation with id: ${jsonEncode(consultation.toMap())}");

    return id;
  }

  Future<int> updateConsultation(Consultation consultation) async {
    Logger.info("Updating Consultation with id ${consultation.id.toString()}");

    final finder = Finder(filter: Filter.byKey(consultation.id));

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(consultation.toMap());

    int id = await _consultationStore.update(
      (await getDb()),
      consultation.toMap(),
      finder: finder,
    );

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(id);

    return id;
  }

  Future<int> delete(Consultation consultation) async {
    Logger.info("Deleting consultation");

    // final finder = Finder(filter: Filter.byKey(consultation.id));
    int id = await _consultationStore.delete(
      (await getDb()),
      //finder: finder,
    );

    return id;
  }

  Future<List<Consultation>> getAllByDateRange(
      DateTime start, DateTime end) async {
    List<Filter> filterList = [];
    if (end != null) {
      filterList.add(
          Filter.greaterThanOrEquals("start", start.millisecondsSinceEpoch));
      filterList
          .add(Filter.lessThanOrEquals("end", end.millisecondsSinceEpoch));
    }

    final finder = Finder(
        filter: Filter.and(filterList), sortOrders: [SortOrder('start')]);

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(finder.toString());

    final recordSnapshots = await _consultationStore.find(
      (await getDb()),
      finder: finder,
    );

    if (GlobalConfiguration().get(C.DEBUG))
      Logger.debug(recordSnapshots.map((snapshot) => snapshot.value).toList());

    return recordSnapshots.map((snapshot) {
      final consultation =
          Consultation.fromMap(snapshot.value as Map<String, dynamic>);
      consultation.id = snapshot.key as int;
      return consultation;
    }).toList();
  }

  Future<List<Consultation>> getAllByDate(DateTime start) async {
    List<Filter> filterList = [];

    DateTime date = DateTime(start.year, start.month, start.day, 0, 0);

    filterList.add(Filter.greaterThanOrEquals(
        "start", date.toLocal().millisecondsSinceEpoch));
    filterList.add(Filter.lessThanOrEquals("end",
        date.toLocal().add(const Duration(days: 1)).millisecondsSinceEpoch));

    final finder = Finder(
        filter: Filter.and(filterList), sortOrders: [SortOrder('start')]);

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(finder.toString());

    final recordSnapshots = await _consultationStore.find(
      (await getDb()),
      finder: finder,
    );

    if (GlobalConfiguration().get(C.DEBUG)) {
      Logger.debug(recordSnapshots.map((snapshot) => snapshot.value).toList());
    }

    return recordSnapshots.map((snapshot) {
      final consultation =
          Consultation.fromMap(snapshot.value as Map<String, dynamic>);
      consultation.id = snapshot.key as int;
      return consultation;
    }).toList();
  }

  Future<List<Consultation>> seacrhBy(SearchOption option, String searchStr,
      {DateTime? start, DateTime? end}) async {
    Logger.info("Getting Consultations By Date: ${searchStr}");
    List<Filter> filterList = [];

    if (searchStr.isNotEmpty) {
      if (option == SearchOption.SearchByName) {
        filterList.add(Filter.equals("patient_name", searchStr));
      }
    }

    if (start != null && end != null) {
      filterList.add(
          Filter.greaterThanOrEquals("start", start.millisecondsSinceEpoch));
      filterList
          .add(Filter.lessThanOrEquals("end", end.millisecondsSinceEpoch));
    } else if (start != null) {
      filterList.add(
          Filter.greaterThanOrEquals("start", start.millisecondsSinceEpoch));
    } else if (end != null) {
      filterList
          .add(Filter.lessThanOrEquals("end", end.millisecondsSinceEpoch));
    }

    if (GlobalConfiguration().get(C.DEBUG))
      Logger.debug(filterList.map((filter) => filter.toString()).toList());

    final recordSnapshots = await _consultationStore.find((await getDb()),
        finder: Finder(filter: Filter.and(filterList)));

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(recordSnapshots);

    List<Consultation> consultationList = recordSnapshots.map((snapshot) {
      final consultation =
          Consultation.fromMap(snapshot.value as Map<String, dynamic>);
      consultation.id = snapshot.key as int;
      return consultation;
    }).toList();

    return consultationList;
  }

  Future<Consultation> findById(String id) async {
    Logger.info("Get consultation for event : ${id}");

    final recordSnapshots = await _consultationStore.find(
      (await getDb()),
      finder: Finder(filter: Filter.matches("id", id)),
    );

    if (recordSnapshots.isNotEmpty && GlobalConfiguration().get(C.DEBUG))
      Logger.debug(recordSnapshots.first.value);

    RecordSnapshot consultationMap = recordSnapshots.firstWhere((snapshot) =>
        (Consultation.fromMap(snapshot.value as Map<String, dynamic>).id ==
            id));
    Consultation consultation =
        Consultation.fromMap(consultationMap.value as Map<String, dynamic>);

    return consultation;
  }

  Future<int> clearAll() async {
    Logger.info("Delete All Consultation ");
    return await _consultationStore.delete(
      (await getDb()),
    );
  }

  Future<int> deleteAllInList(List<String> eventIdList) async {
    Logger.info(
        "Delete All Consultations for events: ${eventIdList.toString()}");

    final finder = Finder(filter: Filter.inList("eventId", eventIdList));

    if (GlobalConfiguration().get(C.DEBUG)) Logger.debug(finder.toString());

    int count = await _consultationStore.delete(
      (await getDb()),
      finder: finder,
    );

    return count;
  }

  Future<DateTime> getMaxDate() async {
    DateTime maxDate = DateTime.now();

    final recordSnapshots = await _consultationStore.find((await getDb()));

    if (recordSnapshots.isNotEmpty) {
      List<int> dateList =
          recordSnapshots.map((record) => record['start'] as int).toList();
      maxDate = DateTime.fromMillisecondsSinceEpoch(
          dateList.reduce((current, next) => max(current, next)));
    }

    return maxDate;
  }

  Future<DateTime> getMinDate() async {
    DateTime minDate = DateTime.now();

    final recordSnapshots = await _consultationStore.find((await getDb()));

    if (recordSnapshots.isNotEmpty) {
      List<int> dateList =
          recordSnapshots.map((record) => record['start'] as int).toList();
      minDate = DateTime.fromMillisecondsSinceEpoch(
          dateList.reduce((current, next) => min(current, next)));
    }

    return minDate;
  }

  Future<int> getCount() async {
    final recordSnapshots = await _consultationStore.find((await getDb()));
    return recordSnapshots.length;
  }
}
