import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golyapooch/features/match/application/match_cubit.dart';
import 'package:golyapooch/features/match/domain/match_rules.dart';
import 'package:golyapooch/features/match/domain/match_state.dart';

void main(){
  setUp(()=>SharedPreferences.setMockInitialValues({}));
  MatchCubit create() => MatchCubit(MatchState.start(
    const MatchSettings(mode:GameMode.nabardGol),'A','B'));
  test('Normal capture transfers flower without points',() {
    final cubit=create();
    cubit.normalCapture();
    expect(cubit.state.scores,[0,0]);
    expect(cubit.state.holder,1);
    cubit.close();
  });
  test('First strike grants two points',() {
    final cubit=create();
    cubit.normalCapture(firstStrike:true);
    expect(cubit.state.scores,[0,2]);
    cubit.close();
  });
  test('Poison empty is free and does not consume three empty guesses',(){
    final cubit=create();
    cubit.playCard(CardPower.poisonHand);
    cubit.respondToCard(nullify:false);
    cubit.specialChoice(correct:false);
    expect(cubit.state.emptyGuesses,0);
    expect(cubit.state.freePoisonEmpty,true);
    expect(cubit.state.phase,RoundPhase.guess);
    cubit.close();
  });
  test('Hunter gets flower without a point',(){
    final cubit=create();
    cubit.playCard(CardPower.hunter);
    cubit.respondToCard(nullify:false);
    cubit.specialChoice(correct:true);
    expect(cubit.state.scores,[0,0]);
    expect(cubit.state.holder,1);
    cubit.close();
  });
  test('Nullifying burns offensive and defensive cards',(){
    final cubit=create();
    cubit.playCard(CardPower.doubleSword);
    cubit.respondToCard(nullify:true);
    expect(cubit.state.nullifiers,[1,2]);
    expect(cubit.state.cards[1].contains(CardPower.doubleSword),false);
    expect(cubit.state.power,isNull);
    cubit.close();
  });
  test('Timer offers final attempt',(){
    final cubit=MatchCubit(MatchState.start(const MatchSettings(
      mode:GameMode.nabardGol,turnSeconds:15),'A','B').copyWith(secondsLeft:1));
    cubit.tick();
    expect(cubit.state.phase,RoundPhase.finalGuess);
    cubit.normalCapture();
    expect(cubit.state.holder,1);
    cubit.close();
  });
  test('Crown failure allows retreat and deducts three',(){
    final initial=MatchState.start(const MatchSettings(mode:GameMode.nabardGol,target:8),
      'A','B').copyWith(scores:[7,2]);
    final cubit=MatchCubit(initial);
    cubit.normalCapture();
    expect(cubit.state.phase,RoundPhase.crownChoice);
    cubit.crownRetreat();
    expect(cubit.state.scores[0],4);
    expect(cubit.state.holder,1);
    cubit.close();
  });
  test('Duel is one attempt and owner victory finishes match',(){
    final initial=MatchState.start(const MatchSettings(mode:GameMode.nabardGol,target:8),
      'A','B').copyWith(scores:[7,1]);
    final cubit=MatchCubit(initial);
    cubit.normalCapture();
    cubit.chooseCaptainDuel();
    expect(cubit.state.phase,RoundPhase.captainDuel);
    cubit.resolveCaptainDuel(ownerProtected:true);
    expect(cubit.state.winner,0);
    cubit.close();
  });
}
