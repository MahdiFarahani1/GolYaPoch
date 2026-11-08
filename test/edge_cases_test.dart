import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golyapooch/features/match/application/match_cubit.dart';
import 'package:golyapooch/features/match/domain/match_rules.dart';
import 'package:golyapooch/features/match/domain/match_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  MatchCubit fresh({int target = 21, bool shah = true}) =>
      MatchCubit(MatchState.start(MatchSettings(
        mode: GameMode.nabardGol, target: target, shahGolEnabled: shah), 'الف', 'ب'));

  test('A nullified offensive card cannot be played again in that hand', () {
    final c = fresh();
    c.playCard(CardPower.doubleSword);
    c.respondToCard(nullify: true);
    expect(c.state.canPlayCard, false);
    expect(c.state.offensiveUsed, true);
    expect(c.state.defensiveUsed, true);
    expect(c.state.cards[c.state.guesser].length, 4);
    expect(c.state.nullifiers[c.state.holder], 1);
    c.normalCapture();
    expect(c.state.offensiveUsed, false);
    expect(c.state.defensiveUsed, false);
    c.close();
  });

  test('Double sword awards one independent bonus point for wrong prediction', () {
    final c = fresh();
    c.playCard(CardPower.doubleSword);
    c.respondToCard(nullify: false);
    c.captainPrediction(false);
    c.normalCapture(firstStrike: true);
    expect(c.state.scores, [0, 3]);
    c.close();
  });

  test('Double sword correct prediction awards point to hiding team', () {
    final c = fresh();
    c.playCard(CardPower.doubleSword);
    c.respondToCard(nullify: false);
    c.captainPrediction(true);
    c.normalCapture();
    expect(c.state.scores, [1, 0]);
    expect(c.state.holder, 1);
    c.close();
  });

  test('Hourglass makes one choice and gives four on success', () {
    final c = fresh();
    c.playCard(CardPower.hourglass);
    c.respondToCard(nullify: false);
    expect(c.state.secondsLeft, 45);
    c.specialChoice(correct: true);
    expect(c.state.scores, [0,4]);
    c.close();
  });

  test('Phoenix can succeed after empty play and awards tiered points', () {
    final starting=MatchState.start(const MatchSettings(mode: GameMode.nabardGol),
        'الف','ب').copyWith(scores: [6,0]);
    final c=MatchCubit(starting);
    c.playCard(CardPower.phoenix);
    c.respondToCard(nullify: false);
    c.emptyGuess();
    c.normalCapture();
    expect(c.state.scores, [6,4]);
    c.close();
  });

  test('Phoenix is unavailable if deficit is below three', () {
    final c=fresh();
    c.playCard(CardPower.phoenix);
    expect(c.state.cards[c.state.guesser].length, 5);
    expect(c.state.power, null);
    c.close();
  });

  test('Poison missed choice leaves all three empties available', () {
    final c=fresh();
    c.playCard(CardPower.poisonHand);
    c.respondToCard(nullify: false);
    c.specialChoice(correct: false);
    for (var i=0;i<3;i++) c.emptyGuess();
    expect(c.state.emptyGuesses,3);
    expect(c.state.phase,RoundPhase.finalGuess);
    c.close();
  });

  test('Retreat never produces negative scores in 8 point game', () {
    final s=MatchState.start(const MatchSettings(mode: GameMode.nabardGol,target: 8),
      'الف','ب').copyWith(scores:[7,0]);
    final c=MatchCubit(s);
    c.normalCapture();
    c.crownRetreat();
    expect(c.state.scores[0],4);
    c.close();
  });

  test('Filimo can turn off cube; Shah Gol always requires one', () {
    const f=MatchSettings(mode:GameMode.filimo,filimoCubeEnabled:false);
    const s=MatchSettings(mode:GameMode.shahGol,filimoCubeEnabled:false);
    expect(f.canConfigureCube,true);
    expect(s.canConfigureCube,false);
  });

  test('Filimo first crown loss deducts three points', () {
    final s=MatchState.start(const MatchSettings(mode:GameMode.filimo,target:15),
      'الف','ب').copyWith(scores:[14,2]);
    final c=MatchCubit(s);
    c.manualEvent(found:true,points:0);
    expect(c.state.scores[0],11);
    expect(c.state.phase,RoundPhase.guess);
    expect(c.state.shahLosses[0],1);
    c.close();
  });
}
