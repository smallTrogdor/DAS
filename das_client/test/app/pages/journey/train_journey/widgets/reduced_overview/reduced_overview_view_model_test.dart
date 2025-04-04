import 'package:das_client/app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_view_model.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/balise_level_crossing_group.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:das_client/model/journey/tram_area.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:das_client/model/ru.dart';
import 'package:das_client/model/train_identification.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'reduced_overview_view_model_test.mocks.dart';

final trainIdentification = TrainIdentification(ru: Ru.sbbP, trainNumber: '1234', date: DateTime.now());

@GenerateNiceMocks([
  MockSpec<SferaLocalService>(),
])
void main() {
  test('test metadata is correctly emitted', () {
    final metadata = Metadata(timestamp: DateTime.now());
    final sferaServiceMock = _setupSferaServiceMock(metadata, <BaseData>[]);

    final viewModel =
        ReducedOverviewViewModel(trainIdentification: trainIdentification, sferaLocalService: sferaServiceMock);

    expect(viewModel.journeyMetadata, emits(metadata));
  });

  test('test only service points with stop or communication network change are emitted', () {
    // GIVEN
    final stop1 = ServicePoint(name: LocalizedString(), order: 100, kilometre: [], isStop: true);
    final withoutStop = ServicePoint(name: LocalizedString(), order: 200, kilometre: [], isStop: false);
    final stop2 = ServicePoint(name: LocalizedString(), order: 300, kilometre: [], isStop: true);
    final withoutStopWithNetworkChange =
        ServicePoint(name: LocalizedString(), order: 400, kilometre: [], isStop: false);
    final data = <BaseData>[stop1, withoutStop, stop2, withoutStopWithNetworkChange];

    final communicationNetworkChanges = [CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 400)];
    final metadata = Metadata(communicationNetworkChanges: communicationNetworkChanges);

    final sferaServiceMock = _setupSferaServiceMock(metadata, data);
    final viewModel =
        ReducedOverviewViewModel(trainIdentification: trainIdentification, sferaLocalService: sferaServiceMock);

    // WHEN
    final dataStream = viewModel.journeyData;

    // THEN
    expect(dataStream, emits([stop1, stop2, withoutStopWithNetworkChange]));
  });

  test('test only service points and ASR are emitted', () {
    // GIVEN
    final servicePoint = ServicePoint(name: LocalizedString(), order: 100, kilometre: [], isStop: true);
    final curve = CurvePoint(order: 200, kilometre: []);
    final signal = Signal(order: 300, kilometre: []);
    final protectionSection = ProtectionSection(isOptional: true, isLong: true, order: 400, kilometre: []);
    final connectionTrack = ConnectionTrack(order: 500, kilometre: []);
    final tramArea = TramArea(order: 600, kilometre: [], endKilometre: 0.0, amountTramSignals: 0);
    final whistle = Whistle(order: 700, kilometre: []);
    final speedChange = SpeedChange(order: 800, kilometre: [], speedData: SpeedData());
    final balise = Balise(order: 900, kilometre: [], amountLevelCrossings: 0);
    final levelCrossing = LevelCrossing(order: 1000, kilometre: []);
    final baliseLevelCrossingGroup = BaliseLevelCrossingGroup(order: 1100, kilometre: [], groupedElements: []);
    final cabSignaling = CABSignaling(order: 1200, kilometre: []);
    final asr = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 1300, orderTo: 1400);
    final asrData = AdditionalSpeedRestrictionData(restriction: asr, order: 1300, kilometre: []);

    final data = <BaseData>[
      servicePoint,
      curve,
      signal,
      protectionSection,
      connectionTrack,
      tramArea,
      whistle,
      speedChange,
      balise,
      levelCrossing,
      baliseLevelCrossingGroup,
      cabSignaling,
      asrData,
    ];
    final sferaServiceMock = _setupSferaServiceMock(Metadata(), data);
    final viewModel =
        ReducedOverviewViewModel(trainIdentification: trainIdentification, sferaLocalService: sferaServiceMock);

    // WHEN
    final dataStream = viewModel.journeyData;

    // THEN
    expect(dataStream, emits([servicePoint, asrData]));
  });

  test('test duplicated ASR are removed', () {
    // GIVEN
    final asr1 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 100, orderTo: 200);
    final asrData1 = AdditionalSpeedRestrictionData(restriction: asr1, order: 100, kilometre: []);
    final asr2 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 300, orderTo: 400);
    final asrData2 = AdditionalSpeedRestrictionData(restriction: asr2, order: 200, kilometre: []);
    final data = <BaseData>[asrData1, asrData1, asrData2];
    final sferaServiceMock = _setupSferaServiceMock(Metadata(), data);
    final viewModel =
        ReducedOverviewViewModel(trainIdentification: trainIdentification, sferaLocalService: sferaServiceMock);

    // WHEN
    final dataStream = viewModel.journeyData;

    // THEN
    expect(dataStream, emits([asrData1, asrData2]));
  });
}

MockSferaLocalService _setupSferaServiceMock(Metadata metadata, List<BaseData> data) {
  final sferaServiceMock = MockSferaLocalService();
  final journey = Journey(metadata: metadata, data: data);
  when(sferaServiceMock.journeyStream(
    company: trainIdentification.ru.companyCode,
    trainNumber: trainIdentification.trainNumber,
    startDate: trainIdentification.date,
  )).thenAnswer((_) => Stream.value(journey));
  return sferaServiceMock;
}
