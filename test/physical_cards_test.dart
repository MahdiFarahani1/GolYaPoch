import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golyapooch/features/match/application/match_cubit.dart';
import 'package:golyapooch/features/match/domain/match_rules.dart';
import 'package:golyapooch/features/match/domain/match_state.dart';
import 'package:golyapooch/features/match/domain/physical_cards.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Each Filimo deck has five physically distinct card slots', () {
    for (var seed = 1; seed <= 40; seed++) {
      final d = PhysicalCards.filimoDeck(seed);
      expect(d.length, 5);
      expect(d.toSet().length, 5);
      expect(['antenna','duel'].contains(d[0]), isTrue);
      expect(['largeSphere','soundSphere'].contains(d[1]), isTrue);
      expect(d.every(PhysicalCards.all.containsKey), isTrue);
    }
  });

  test('Reference card use consumes only one card per hand', () {
    final c=MatchCubit(MatchState.start(
      const MatchSettings(mode:GameMode.filimo),'A','B'));
    final cards=c.state.physicalCards[1].toList();
    c.manualUseCard(cards.first);
    expect(c.state.physicalCards[1].length,4);
    expect(c.state.offensiveUsed,true);
    c.manualUseCard(cards.last);
    expect(c.state.physicalCards[1].length,4);
    c.manualEvent(found:true,points:0);
    expect(c.state.offensiveUsed,false);
    c.close();
  });

  test('Filimo prohibits using cards during Shah Gol', () {
    final s=MatchState.start(
      const MatchSettings(mode:GameMode.filimo,target:15),
      'A','B').copyWith(scores:[14,1]);
    final c=MatchCubit(s);
    c.manualUseCard(c.state.physicalCards[1].first);
    expect(c.state.physicalCards[1].length,5);
    expect(c.state.offensiveUsed,false);
    c.close();
  });

  test('Shah Gol milli is tracked and spent at a referee-specified cost', () {
    final c=MatchCubit(MatchState.start(
      const MatchSettings(mode:GameMode.shahGol),'A','B'));
    c.manualAdjustMilli(1,4);
    expect(c.state.milliBalances[1],4);
    c.manualUseCard('taftish',milliCost:3);
    expect(c.state.milliBalances[1],1);
    expect(c.state.physicalCards[1].contains('taftish'),false);
    c.close();
  });

  test('Match pause prevents timer consumption', () {
    final c=MatchCubit(MatchState.start(
      const MatchSettings(mode:GameMode.nabardGol),'A','B'));
    c.togglePause();
    expect(c.state.isPaused,true);
    final before=c.state.secondsLeft;
    c.tick();
    expect(c.state.secondsLeft,before);
    c.togglePause();
    c.tick();
    expect(c.state.secondsLeft,before-1);
    c.close();
  });

  test('Manual inventory survives JSON restore', () {
    final s=MatchState.start(const MatchSettings(mode:GameMode.shahGol),'A','B')
      .copyWith(milliBalances:[3,5],isPaused:true);
    final restored=MatchState.fromJson(s.toJson());
    expect(restored.milliBalances,[3,5]);
    expect(restored.physicalCards[0].length,5);
    expect(restored.isPaused,true);
  });
}
