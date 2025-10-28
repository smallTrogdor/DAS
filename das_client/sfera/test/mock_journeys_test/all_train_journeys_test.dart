import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';

class TestJourney {
  const TestJourney({required this.journey, required this.name, this.eventName});

  final Journey journey;
  final String name;
  final String? eventName;
}

/// Uses [SferaReplyParser] and [SferaModelMapper] to parse journeys from static resources in directories
/// to a [TestJourney] with JOURNEY_NAME as name field.
///
/// ```
/// test_journey
/// │   SFERA_JP_JOURNEY_NAME.xml
/// │   SFERA_SP_JOURNEY_NAME_*.xml (m times)
/// │   SFERA_TC_JOURNEY_NAME_*.xml
/// │   SFERA_Event_JOURNEY_NAME_*.xml (n times)
/// ```
///
/// Will consider all subdirs containing exactly one SFERA_JP_*, at least one SFERA_SP_*
/// and at least one SFERA_TC_* file.
///
/// In case there are event files with JP updates, will create multiple journeys, one for each JP update event.
class TestJourneyLoader {
  static const _sferaStaticResourcesDirPath = '../../sfera_mock/src/main/resources/static_sfera_resources';
  static const _clientTestResourcesDirPath = './test_resources';

  static List<TestJourney> fromStaticSferaResources() => fromRootDir(Directory(_sferaStaticResourcesDirPath));

  static List<TestJourney> fromClientTestResources() => fromRootDir(Directory(_clientTestResourcesDirPath));

  static List<TestJourney> fromRootDir(Directory rootDir) {
    final result = <TestJourney>[];

    final subdirs = rootDir.listSync(recursive: true).whereType<Directory>();

    for (final dir in subdirs) {
      final files = dir.listSync().whereType<File>().toList();

      final jpFiles = files.where((f) => f.path.contains('SFERA_JP_')).toList();
      final spFiles = files.where((f) => f.path.contains('SFERA_SP_')).toList();
      final tcFiles = files.where((f) => f.path.contains('SFERA_TC_')).toList();
      final eventFiles = files.where((f) => f.path.contains('SFERA_Event_')).toList();

      if (jpFiles.isEmpty || spFiles.isEmpty || jpFiles.length > 1) {
        continue;
      }

      final jpFile = jpFiles.first;
      final nameRegEx = RegExp('(?<=SFERA_JP_).*(?=.xml)');
      final journeyName = nameRegEx.firstMatch(jpFile.path)?[0];

      if (journeyName == null) continue;

      final baseJourneyProfile = SferaReplyParser.parse<JourneyProfileDto>(jpFile.readAsStringSync());

      final segmentProfiles = spFiles
          .map((f) => SferaReplyParser.parse<SegmentProfileDto>(f.readAsStringSync()))
          .toList();

      final trainCharacteristics = tcFiles
          .map((f) => SferaReplyParser.parse<TrainCharacteristicsDto>(f.readAsStringSync()))
          .toList();

      final journey = SferaModelMapper.mapToJourney(
        journeyProfile: baseJourneyProfile,
        segmentProfiles: segmentProfiles,
        trainCharacteristics: trainCharacteristics,
      );
      result.add(TestJourney(journey: journey, name: journeyName));

      for (final file in eventFiles) {
        final nameRegEx = RegExp('(?<=SFERA_Event_${journeyName}_).*(?=.xml)');
        final eventName = nameRegEx.firstMatch(file.path)?[0];
        if (eventName == null) continue;

        final event = SferaReplyParser.parse<G2bEventPayloadDto>(file.readAsStringSync());

        final eventJourneyProfile = event.journeyProfiles.firstOrNull;
        final relatedTrainInformation = event.relatedTrainInformation;

        if (eventJourneyProfile != null) {
          final journey = SferaModelMapper.mapToJourney(
            journeyProfile: eventJourneyProfile,
            segmentProfiles: segmentProfiles,
            trainCharacteristics: trainCharacteristics,
            relatedTrainInformation: relatedTrainInformation,
          );
          result.add(TestJourney(journey: journey, name: journeyName, eventName: eventName));
        }

        if (relatedTrainInformation != null && eventJourneyProfile == null) {
          final journey = SferaModelMapper.mapToJourney(
            journeyProfile: baseJourneyProfile,
            segmentProfiles: segmentProfiles,
            trainCharacteristics: trainCharacteristics,
            relatedTrainInformation: relatedTrainInformation,
          );
          result.add(TestJourney(journey: journey, name: journeyName, eventName: eventName));
        }
      }
    }

    return result;
  }
}

void main() {
  const sferaStaticResourcesDirectoryPath = '../../sfera_mock/src/main/resources/static_sfera_resources';
  final testResourcesDir = Directory(sferaStaticResourcesDirectoryPath);

  test('whenSferaStaticResourcesDirPath_thenShouldFindDirectory', tags: 'sfera-mock-data-validator', () {
    expect(testResourcesDir.existsSync(), isTrue);
  });

  group('whenLoadingAllJourneysFromTestResourcesDir_thenShouldAllBeValid', () {
    for (final testJourney in TestJourneyLoader.fromStaticSferaResources()) {
      final journeyName = [testJourney.name, testJourney.eventName].join('-');
      test('whenParsingJourney_${journeyName}_thenShouldBeValid', tags: 'sfera-mock-data-validator', () {
        expect(testJourney.journey.valid, isTrue);
      });
    }
  });

  group('whenLoadingAllJourneysFromTestResourcesDir_thenShouldAllBeValid', () {
    for (final testJourney in TestJourneyLoader.fromClientTestResources()) {
      final journeyName = [testJourney.name, testJourney.eventName].nonNulls.join('-');
      test('whenParsingJourney_${journeyName}_thenShouldBeValid', tags: 'sfera-mock-data-validator', () {
        expect(testJourney.journey.valid, isTrue);
      });
    }
  });
}
