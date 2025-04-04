import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/sfera_reply_parser.dart';
import 'package:isar/isar.dart';

part 'segment_profile_entity.g.dart';

@Collection(accessor: 'segmentProfile')
class SegmentProfileEntity {
  SegmentProfileEntity(
      {required this.id,
      required this.spId,
      required this.majorVersion,
      required this.minorVersion,
      required this.xmlData});

  final int id;
  final String spId;
  final String majorVersion;
  final String minorVersion;
  final String xmlData;

  SegmentProfile toDomain() {
    return SferaReplyParser.parse<SegmentProfile>(xmlData);
  }
}

extension SegmentProfileMapperX on SegmentProfile {
  SegmentProfileEntity toEntity({required int isarId}) {
    return SegmentProfileEntity(
        id: isarId,
        spId: this.id,
        majorVersion: versionMajor,
        minorVersion: versionMinor,
        xmlData: buildDocument().toString());
  }
}
