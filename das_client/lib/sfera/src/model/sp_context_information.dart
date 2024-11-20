import 'package:das_client/sfera/src/model/kilometre_reference_point.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class SpContextInformation extends SferaXmlElement {
  static const String elementType = 'SP_ContextInformation';

  SpContextInformation({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<KilometreReferencePoint> get kilometreReferencePoints => children.whereType<KilometreReferencePoint>();
}
