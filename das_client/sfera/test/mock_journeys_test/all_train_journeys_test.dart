import 'dart:io';

import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';



/// Uses [SferaReplyParser] and [SferaModelMapper] to parse a test journey to a [Journey] in a directory.
///
/// Will consider all subdirs containing a SFERA_JP_*, at least one SFERA_SP_* and at least one SFERA_TC_ file.
///
/// In case there are SFERA_Event files present in a directory, multiple journeys will be returned, one for each event.
class TestJourneyLoader {
  static Iterable<Journey> fromRootDir(Directory rootDir) {
    final journeys = <Journey>[];

    // Find all subdirectories
    final subdirs = rootDir.listSync(recursive: true).whereType<Directory>();

    for (final dir in subdirs) {
      final files = dir.listSync().whereType<File>().toList();

      // Check if directory contains required files
      final jpFiles = files.where((f) => f.path.contains('SFERA_JP_')).toList();
      final spFiles = files.where((f) => f.path.contains('SFERA_SP_')).toList();
      final tcFiles = files.where((f) => f.path.contains('SFERA_TC_')).toList();

      if (jpFiles.isEmpty || spFiles.isEmpty || tcFiles.isEmpty) {
        continue;
      }

      print(dir);
      //
      // Parse DTOs
      final journeyProfile = SferaReplyParser.parse<JourneyProfileDto>(
        jpFiles.first.readAsStringSync(),
      );

        final segmentProfiles = spFiles
            .map(
              (f) => SferaReplyParser.parse<SegmentProfileDto>(f.readAsStringSync()),
            )
            .toList();

        final trainCharacteristics = tcFiles
            .map(
              (f) => SferaReplyParser.parse<TrainCharacteristicsDto>(f.readAsStringSync()),
            )
            .toList();

        // Map to Journey
        final journey = SferaModelMapper.mapToJourney(
          journeyProfile: journeyProfile,
          segmentProfiles: segmentProfiles,
          trainCharacteristics: trainCharacteristics,
        );

        journeys.add(journey);
      }

      return journeys;
      }
    }

main() {
  final testDir = Directory('../../../sfera_mock/src/main/resources/static_sfera_resources');
  assert(testDir.existsSync(), 'rootDir not found!');
  TestJourneyLoader.fromRootDir(testDir);
}