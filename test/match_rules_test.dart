import 'package:flutter_test/flutter_test.dart';
import 'package:golyapooch/features/match/domain/match_rules.dart';
import 'package:golyapooch/features/match/domain/match_state.dart';

void main() {
  test('All modes permit 8–31 point targets and optional Shah', () {
    for(final mode in GameMode.values) {
      for(final target in [8,15,20,21,31]) {
        final s=MatchSettings(mode:mode,target:target);
        expect(s.shahThreshold,target-1);
        expect(s.scoreCap,target-1);
        expect(MatchSettings(mode:mode,target:target,shahGolEnabled:false).scoreCap,target);
      }
    }
  });
  test('Shah cap prevents bypass and direct mode reaches target', () {
    final capped=MatchSettings(mode:GameMode.nabardGol,target:15);
    expect(CustomRules.addPoints(12,4,capped),14);
    final direct=MatchSettings(mode:GameMode.nabardGol,target:15,shahGolEnabled:false);
    expect(CustomRules.addPoints(12,4,direct),15);
  });
  test('Phoenix tiers', () {
    expect(CustomRules.phoenixPoints(3),3);
    expect(CustomRules.phoenixPoints(5),3);
    expect(CustomRules.phoenixPoints(6),4);
    expect(CustomRules.phoenixPoints(9),4);
    expect(CustomRules.phoenixPoints(10),5);
    expect(()=>CustomRules.phoenixPoints(2),throwsArgumentError);
  });
  test('Match state JSON roundtrip keeps cards and score', () {
    final state=MatchState.start(const MatchSettings(mode:GameMode.nabardGol),
      'زرین','لاجورد');
    final restored=MatchState.fromJson(state.toJson());
    expect(restored.teams,['زرین','لاجورد']);
    expect(restored.cards[0].length,5);
    expect(restored.nullifiers,[2,2]);
    expect(restored.settings.mode,GameMode.nabardGol);
  });
}
