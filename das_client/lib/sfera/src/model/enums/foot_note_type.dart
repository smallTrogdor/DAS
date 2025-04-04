import 'package:das_client/model/journey/foot_note.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum SferaFootNoteType implements XmlEnum {
  trackSpeed(xmlValue: 'trackSpeed', footNoteType: FootNoteType.trackSpeed),
  decisiveGradientUp(xmlValue: 'decisiveGradientUp', footNoteType: FootNoteType.decisiveGradientUp),
  decisiveGradientDown(xmlValue: 'decisiveGradientDown', footNoteType: FootNoteType.decisiveGradientDown),
  contact(xmlValue: 'contact', footNoteType: FootNoteType.contact),
  networkType(xmlValue: 'networkType', footNoteType: FootNoteType.networkType),
  journey(xmlValue: 'journey', footNoteType: FootNoteType.journey);

  const SferaFootNoteType({
    required this.xmlValue,
    required this.footNoteType,
  });

  @override
  final String xmlValue;

  final FootNoteType footNoteType;
}
