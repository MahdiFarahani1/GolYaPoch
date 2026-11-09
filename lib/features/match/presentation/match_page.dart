import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/royal_theme.dart';
import '../../../core/widgets/royal_widgets.dart';
import '../../guide/guide_page.dart';
import '../application/match_cubit.dart';
import '../domain/physical_cards.dart';
import '../domain/match_rules.dart';
import '../domain/match_state.dart';

class MatchPage extends StatelessWidget {
  const MatchPage({super.key, required this.initial});
  final MatchState initial;
  @override Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>MatchCubit(initial),child:const _MatchBody());
}
class _MatchBody extends StatefulWidget {
  const _MatchBody();
  @override State<_MatchBody> createState()=>_MatchBodyState();
}
class _MatchBodyState extends State<_MatchBody> {
  Timer? ticker;
  @override void initState(){
    super.initState();
    ticker=Timer.periodic(const Duration(seconds:1),(t){
      if(mounted)context.read<MatchCubit>().tick();
    });
  }
  @override void dispose(){ticker?.cancel();super.dispose();}
  @override Widget build(BuildContext context) {
    final cubit=context.read<MatchCubit>();
    return BlocBuilder<MatchCubit,MatchState>(builder:(context,s)=>RoyalScaffold(
      appBar:AppBar(title:Text(s.settings.mode.title),actions:[
        IconButton(tooltip:'بازگشت حرکت',onPressed:cubit.canUndo?cubit.undo:null,
          icon:const Icon(Icons.undo_rounded)),
        IconButton(tooltip:'قوانین',onPressed:()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>GuidePage(mode:s.settings.mode))),
          icon:const Icon(Icons.menu_book_outlined)),
      ]),
      child:ListView(padding:const EdgeInsets.fromLTRB(17,66,17,30),children:[
        if(s.isShahHand)RoyalPanel(highlight:true,child:const Row(children:[
          Icon(Icons.workspace_premium_outlined,color:RoyalTheme.gold),
          SizedBox(width:10),Expanded(child:Text('شاه‌گل! • یک قدم تا تاج',
            style:TextStyle(fontSize:16,fontWeight:FontWeight.w900)))])),
        const SizedBox(height:13),
        Row(children:[
          Expanded(child:_ScoreCard(team:s.teams[0],score:s.scores[0],
            isHolder:s.holder==0,color:RoyalTheme.teal)),
          const SizedBox(width:10),
          const Text('VS',style:TextStyle(fontSize:14,fontWeight:FontWeight.w900,color:RoyalTheme.gold)),
          const SizedBox(width:10),
          Expanded(child:_ScoreCard(team:s.teams[1],score:s.scores[1],
            isHolder:s.holder==1,color:RoyalTheme.burgundy)),
        ]),
        const SizedBox(height:14),
        RoyalPanel(child:Column(children:[
          Text('دست شماره ${s.hand}  •  هدف ${s.settings.target}',
            style:const TextStyle(fontSize:12,color:RoyalTheme.muted)),
          const SizedBox(height:12),
          const CrownArt(size:56),
          const SizedBox(height:8),
          Text(s.phase==RoundPhase.finished?'قهرمان مسابقه'
            :s.phase==RoundPhase.crownChoice?'بهای تاج'
            :s.phase==RoundPhase.captainDuel?'دوئل کاپیتان‌ها'
            :s.phase==RoundPhase.defendCard?'فرصت خنثی‌سازی'
            :s.phase==RoundPhase.predict?'پیش‌بینی کاپیتان'
            :'نوبت حدس',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
          const SizedBox(height:7),
          Text(s.note,textAlign:TextAlign.center,style:const TextStyle(color:RoyalTheme.muted)),
          const SizedBox(height:9),
          Text(s.phase==RoundPhase.finished?'تمام شد':'${s.secondsLeft} ثانیه',
            style:const TextStyle(fontSize:34,fontWeight:FontWeight.w900,
              color:RoyalTheme.paleGold,fontFeatures:[FontFeature.tabularFigures()])),
          const SizedBox(height:5),
          LinearProgressIndicator(value:s.secondsLeft/s.settings.turnSeconds,
            backgroundColor:Colors.white10,color:RoyalTheme.gold,minHeight:4,borderRadius:BorderRadius.circular(5)),
        ])),
        const SizedBox(height:13),
        if(s.isFinished)RoyalPanel(highlight:true,child:Column(children:[
          const CrownArt(size:106),
          const SizedBox(height:12),
          Text('${s.teams[s.winner!]} برنده شد!',style:const TextStyle(
            fontSize:23,fontWeight:FontWeight.w900)),
          const SizedBox(height:12),
          FilledButton(onPressed:()=>Navigator.popUntil(context,(r)=>r.isFirst),
            child:const Text('بازگشت به خانه')),
        ]))
        else if(s.isCustom)_CustomActions(state:s,cubit:cubit)
        else _ManualActions(state:s,cubit:cubit),
        if(!s.isFinished && s.phase!=RoundPhase.crownChoice && s.phase!=RoundPhase.captainDuel)
          Padding(padding:const EdgeInsets.only(top:16),child:Text(
            'گل دست «${s.teams[s.holder]}» است • نوبت حدس «${s.teams[s.guesser]}»',
            textAlign:TextAlign.center,style:const TextStyle(color:RoyalTheme.muted,fontSize:12))),
      ]),
    ));
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.team,required this.score,required this.isHolder,required this.color});
  final String team;
  final int score;
  final bool isHolder;
  final Color color;
  @override Widget build(BuildContext context)=>Container(
    padding:const EdgeInsets.symmetric(vertical:16,horizontal:8),
    decoration:BoxDecoration(
      borderRadius:BorderRadius.circular(20),
      gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,
        colors:[color.withValues(alpha:.65),RoyalTheme.ink]),
      border:Border.all(color:isHolder?RoyalTheme.gold:color,width:isHolder?1.8:1)),
    child:Column(children:[
      Text(team,maxLines:1,overflow:TextOverflow.ellipsis,
        style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900)),
      const SizedBox(height:9),
      Text('$score',style:const TextStyle(fontSize:42,color:RoyalTheme.paleGold,fontWeight:FontWeight.w900)),
      Text(isHolder?'● صاحب گل':'در حال حدس',
        style:const TextStyle(fontSize:11,color:RoyalTheme.muted)),
    ]));
}

class _CustomActions extends StatelessWidget {
  const _CustomActions({required this.state,required this.cubit});
  final MatchState state;
  final MatchCubit cubit;
  @override Widget build(BuildContext context) {
    if(state.phase==RoundPhase.crownChoice) return RoyalPanel(highlight:true,child:Column(children:[
      const Text('صاحب تاج چه تصمیمی می‌گیرد؟',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),
      const SizedBox(height:14),
      OutlinedButton(onPressed:cubit.crownRetreat,child:const Text('عقب‌نشینی • کسر ۳ امتیاز')),
      const SizedBox(height:10),
      FilledButton(onPressed:cubit.chooseCaptainDuel,child:const Text('دوئل کاپیتان‌ها • ریسک ۵ امتیاز')),
    ]));
    if(state.phase==RoundPhase.captainDuel)return RoyalPanel(highlight:true,child:Column(children:[
      const Text('یک مخفی‌سازی، یک حدس، بدون کارت',textAlign:TextAlign.center),
      const SizedBox(height:12),
      FilledButton(onPressed:()=>cubit.resolveCaptainDuel(ownerProtected:true),
        child:const Text('صاحب تاج گل را حفظ کرد')),
      const SizedBox(height:10),
      OutlinedButton(onPressed:()=>cubit.resolveCaptainDuel(ownerProtected:false),
        child:const Text('کاپیتان حریف گل را پیدا کرد')),
    ]));
    if(state.phase==RoundPhase.defendCard) return RoyalPanel(child:Column(children:[
      const Text('تیم نگهدارنده می‌خواهد کارت را خنثی کند؟',textAlign:TextAlign.center),
      const SizedBox(height:12),
      FilledButton(onPressed:state.nullifiers[state.holder]>0
        ?()=>cubit.respondToCard(nullify:true):null,
        child:Text('خنثی‌سازی • ${state.nullifiers[state.holder]} کارت باقی‌مانده')),
      const SizedBox(height:10),
      OutlinedButton(onPressed:()=>cubit.respondToCard(nullify:false),
        child:const Text('خیر، کارت اجرا شود')),
    ]));
    if(state.phase==RoundPhase.predict)return RoyalPanel(child:Column(children:[
      const Text('کاپیتان تیم نگهدارنده چه پیش‌بینی می‌کند؟'),
      const SizedBox(height:12),
      FilledButton(onPressed:()=>cubit.captainPrediction(true),child:const Text('گل را پیدا می‌کنند')),
      const SizedBox(height:10),
      OutlinedButton(onPressed:()=>cubit.captainPrediction(false),child:const Text('گل را پیدا نمی‌کنند')),
    ]));
    if(state.phase==RoundPhase.finalGuess && 
      (state.power==CardPower.hunter || state.power==CardPower.hourglass))
      return RoyalPanel(highlight:true,child:Column(children:[
        Text('آخرین انتخاب با ${state.power!.title}',style:const TextStyle(fontWeight:FontWeight.w800)),
        const SizedBox(height:12),
        FilledButton(onPressed:()=>cubit.specialChoice(correct:true),child:const Text('انتخاب صحیح بود')),
        const SizedBox(height:10),
        OutlinedButton(onPressed:()=>cubit.specialChoice(correct:false),child:const Text('انتخاب اشتباه بود')),
      ]));
    if(state.phase==RoundPhase.finalGuess)return RoyalPanel(highlight:true,child:Column(children:[
      const Text('فقط یک انتخاب نهایی باقی‌مانده!',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
      const SizedBox(height:12),
      FilledButton(onPressed:()=>cubit.normalCapture(),child:const Text('گل پیدا شد • بدون امتیاز')),
      const SizedBox(height:10),
      OutlinedButton(onPressed:cubit.failedToFind,child:const Text('گل پیدا نشد')),
    ]));
    return Column(children:[
      if(state.canPlayCard)RoyalPanel(child:Column(children:[
        const RoyalSectionTitle('کارت‌های هجومی باقی‌مانده'),
        SizedBox(height:172,child:ListView(scrollDirection:Axis.horizontal,children:[
          for(final card in state.cards[state.guesser])Padding(
            padding:const EdgeInsets.only(left:10),
            child:GestureDetector(onTap:()=>_showCard(context,card),
              child:SizedBox(width:105,child:Column(children:[
                SizedBox(width:99,height:128,child:SvgPicture.asset(card.asset,fit:BoxFit.contain)),
                Text(card.title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800)),
              ]))),
          ),
        ])),
        const SizedBox(height:6),
        Text('تیم نگهدارنده: ${state.nullifiers[state.holder]} خنثی‌کننده',
          style:const TextStyle(color:RoyalTheme.muted,fontSize:12)),
      ])),
      if(state.power!=null)Padding(padding:const EdgeInsets.only(top:12),
        child:RoyalPanel(highlight:true,child:Column(children:[
          Text('کارت فعال: ${state.power!.title}',
            style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
          const SizedBox(height:7),
          Text(state.power!.description,textAlign:TextAlign.center,
            style:const TextStyle(color:RoyalTheme.muted,fontSize:12)),
          const SizedBox(height:12),
          if(state.power==CardPower.hourglass || state.power==CardPower.hunter || state.power==CardPower.poisonHand)
            ...[
              FilledButton(onPressed:()=>cubit.specialChoice(correct:true),
                child:const Text('کارت موفق بود • گل پیدا شد')),
              const SizedBox(height:9),
              OutlinedButton(onPressed:()=>cubit.specialChoice(correct:false),
                child:const Text('انتخاب اشتباه بود')),
            ],
        ]))),
      if(state.power!=CardPower.hourglass && state.power!=CardPower.hunter && state.power!=CardPower.poisonHand)
        Padding(padding:const EdgeInsets.only(top:12),
          child:RoyalPanel(child:Column(children:[
            const RoyalSectionTitle('داوری گل و پوچ'),
            if(state.emptyGuesses<3)
              OutlinedButton.icon(onPressed:cubit.emptyGuess,
                icon:const Icon(Icons.pan_tool_alt_outlined),
                label:Text('پوچ • ${state.emptyGuesses} از ۳')),
            if(state.emptyGuesses<3)const SizedBox(height:10),
            FilledButton.icon(onPressed:()=>cubit.normalCapture(firstStrike:state.emptyGuesses==0&&!state.freePoisonEmpty),
              icon:const Icon(Icons.auto_awesome),
              label:Text(state.emptyGuesses==0&&!state.freePoisonEmpty?'تک‌ضرب • گل گرفته شد':'گل پیدا شد')),
            const SizedBox(height:9),
            OutlinedButton(onPressed:cubit.failedToFind,child:const Text('گل پیدا نشد • نگهدارنده موفق شد')),
          ]))),
    ]);
  }

  void _showCard(BuildContext context,CardPower power) {
    showModalBottomSheet<void>(context:context,isScrollControlled:true,
      backgroundColor:RoyalTheme.ink,showDragHandle:true,
      builder:(modal)=>Padding(padding:const EdgeInsets.all(22),child:Column(
        mainAxisSize:MainAxisSize.min,children:[
          SizedBox(height:225,child:SvgPicture.asset(power.asset)),
          const SizedBox(height:12),
          Text(power.title,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:RoyalTheme.gold)),
          const SizedBox(height:12),
          Text(power.description,textAlign:TextAlign.center),
          const SizedBox(height:18),
          FilledButton(onPressed:(){
            Navigator.pop(modal);
            cubit.playCard(power);
          },child:const Text('استفاده از کارت')),
          const SizedBox(height:8),
        ])));
  }
}

class _ManualActions extends StatelessWidget {
  const _ManualActions({required this.state, required this.cubit});
  final MatchState state;
  final MatchCubit cubit;

  @override Widget build(BuildContext context) {
    if (state.phase == RoundPhase.captainDuel) {
      final owner = state.crownOwner;
      if (owner == null) return const SizedBox.shrink();
      return RoyalPanel(highlight: true, child: Column(children: [
        const Text('دوئل شاه‌گل فیلیمو', style: TextStyle(
          fontWeight: FontWeight.w900, fontSize: 19)),
        const SizedBox(height: 10),
        const Text('نتیجه دوئل فیزیکی را داور ثبت می‌کند.',
          textAlign: TextAlign.center),
        const SizedBox(height: 15),
        FilledButton(onPressed: () => cubit.resolveCaptainDuel(ownerProtected: true),
          child: Text('برنده: ${state.teams[owner]}')),
        const SizedBox(height: 9),
        OutlinedButton(onPressed: () => cubit.resolveCaptainDuel(ownerProtected: false),
          child: Text('برنده: ${state.teams[1 - owner]}')),
      ]));
    }

    if (state.phase == RoundPhase.crownChoice) {
      return RoyalPanel(highlight: true, child: Column(children: [
        const Text('نتیجه شاه‌گل • داوری با دفترچه اصلی',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        const Text('قانون جریمه یا برد را با نسخه فیزیکی بازی تطبیق دهید.',
          textAlign: TextAlign.center, style: TextStyle(color: RoyalTheme.muted)),
        const SizedBox(height: 14),
        OutlinedButton(onPressed: () => cubit.manualCrownContinue(),
          child: const Text('ادامه مسابقه بدون جریمه')),
        const SizedBox(height: 9),
        OutlinedButton(onPressed: () => cubit.manualCrownContinue(penalty: 3),
          child: const Text('ادامه مسابقه با کسر ۳ امتیاز')),
        const SizedBox(height: 9),
        FilledButton(onPressed: () => cubit.manualDeclareWinner(state.holder),
          child: Text('اعلام برنده: ${state.teams[state.holder]}')),
        const SizedBox(height: 9),
        OutlinedButton(onPressed: () => cubit.manualDeclareWinner(1 - state.holder),
          child: Text('اعلام برنده: ${state.teams[1 - state.holder]}')),
      ]));
    }

    return Column(children: [
      _PhysicalCardDeck(state:state,cubit:cubit),
      const SizedBox(height:13),
      if(state.settings.mode==GameMode.shahGol)
        RoyalPanel(child:Column(children:[
          const RoyalSectionTitle('موجودی میلی • مکعب اصلی'),
          const Text('کسب میلی از مکعب طبق قوانین نسخه فیزیکی ثبت می‌شود.',
            style:TextStyle(color:RoyalTheme.muted,fontSize:12),
            textAlign:TextAlign.center),
          for(var team=0;team<2;team++) Row(children:[
            Expanded(child:Text(state.teams[team],overflow:TextOverflow.ellipsis)),
            IconButton(onPressed:()=>cubit.manualAdjustMilli(team,-1),
              icon:const Icon(Icons.remove_circle_outline,color:RoyalTheme.gold)),
            Text('${state.milliBalances[team]} میلی',style:const TextStyle(
              fontWeight:FontWeight.w900,color:RoyalTheme.paleGold)),
            IconButton(onPressed:()=>cubit.manualAdjustMilli(team,1),
              icon:const Icon(Icons.add_circle_outline,color:RoyalTheme.gold)),
          ]),
        ])),
      if(state.settings.mode==GameMode.filimo && state.settings.filimoCubeEnabled)
        RoyalPanel(child:Row(children:[
          SizedBox(width:78,height:78,child:SvgPicture.asset('assets/cards/cube.svg')),
          const SizedBox(width:13),
          const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('مکعب امتیازافزا فعال',style:TextStyle(
              fontWeight:FontWeight.w900,color:RoyalTheme.gold)),
            SizedBox(height:6),
            Text('مقدار واقعی مکعب را با دکمه‌های داوری ثبت کنید.',
              style:TextStyle(color:RoyalTheme.muted,fontSize:12)),
          ])),
        ])),
      const SizedBox(height:13),
      RoyalPanel(child: Column(children: [
        const RoyalSectionTitle('داوری گل و پوچ'),
        const Text('کارت‌ها و مکعب طبق نسخه واقعی اجرا می‌شوند؛ '
          'نتیجه و امتیاز را در این صفحه ثبت کنید.',
          textAlign: TextAlign.center, style: TextStyle(color: RoyalTheme.muted, fontSize: 12)),
        const SizedBox(height: 14),
        for (final points in [0,1,2,3,4,5])
          Padding(padding: const EdgeInsets.only(bottom: 7),
            child: OutlinedButton(
              onPressed: () => cubit.manualEvent(found: true, points: points),
              child: Text('گل گرفته شد • ${points == 0 ? 'بدون امتیاز' : '$points امتیاز'}'))),
        const SizedBox(height: 8),
        FilledButton(onPressed: () => cubit.manualEvent(found: false, points: 1),
          child: const Text('گل حفظ شد • یک امتیاز')),
      ])),
      const SizedBox(height: 13),
      RoyalPanel(child: Column(children: [
        const RoyalSectionTitle('تنظیم نتیجه توسط داور'),
        for (var team = 0; team < 2; team++)
          Row(children: [
            Expanded(child: Text(state.teams[team], overflow: TextOverflow.ellipsis)),
            IconButton(tooltip: 'کسر امتیاز',
              onPressed: () => cubit.manualAdjustScore(team, -1),
              icon: const Icon(Icons.remove_circle_outline, color: RoyalTheme.gold)),
            IconButton(tooltip: 'افزودن امتیاز',
              onPressed: () => cubit.manualAdjustScore(team, 1),
              icon: const Icon(Icons.add_circle_outline, color: RoyalTheme.gold)),
          ]),
        const SizedBox(height: 10),
        TextButton(onPressed: () => _confirmFinish(context),
          child: const Text('اعلام نتیجه نهایی توسط داور')),
      ])),
    ]);
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final winner = await showDialog<int>(context: context, builder: (dialog) =>
      AlertDialog(title: const Text('کدام تیم برنده شد؟'), actions: [
        for (var i = 0; i < 2; i++) TextButton(
          onPressed: () => Navigator.pop(dialog, i),
          child: Text(state.teams[i])),
      ]));
    if (winner != null) cubit.manualDeclareWinner(winner);
  }
}

class _PhysicalCardDeck extends StatelessWidget {
  const _PhysicalCardDeck({required this.state,required this.cubit});
  final MatchState state;
  final MatchCubit cubit;
  @override Widget build(BuildContext context) {
    final cards=state.physicalCards[state.guesser];
    return RoyalPanel(child:Column(children:[
      const RoyalSectionTitle('کارت‌های باقی‌مانده تیم حدس‌زننده'),
      Text(state.teams[state.guesser],style:const TextStyle(
        color:RoyalTheme.gold,fontWeight:FontWeight.w800)),
      const SizedBox(height:9),
      if(cards.isEmpty)const Text('کارت باقی نمانده',
        style:TextStyle(color:RoyalTheme.muted))
      else SizedBox(height:177,child:ListView(
        scrollDirection:Axis.horizontal,children:[
          for(final id in cards)Padding(padding:const EdgeInsets.only(left:10),
            child:GestureDetector(onTap:()=>_showCard(context,id),
              child:SizedBox(width:100,child:Column(children:[
                SizedBox(height:137,child:SvgPicture.asset(
                  PhysicalCards.all[id]!.asset,fit:BoxFit.contain)),
                const SizedBox(height:7),
                Text(PhysicalCards.all[id]!.title,
                  maxLines:2,textAlign:TextAlign.center,
                  style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800)),
              ]))),
          ),
        ])),
      const SizedBox(height:10),
      Text(state.offensiveUsed?'در این دست کارت استفاده شده است.'
          :'برای دیدن جزئیات، یک کارت را لمس کنید.',
        style:const TextStyle(fontSize:11,color:RoyalTheme.muted)),
    ]));
  }

  void _showCard(BuildContext context,String id) {
    final card=PhysicalCards.all[id]!;
    final cost=ValueNotifier<int>(0);
    final available=state.milliBalances[state.guesser];
    showModalBottomSheet<void>(context:context,showDragHandle:true,
      backgroundColor:RoyalTheme.ink,isScrollControlled:true,
      builder:(modal)=>SafeArea(child:Padding(
        padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
          SizedBox(height:198,child:SvgPicture.asset(card.asset)),
          const SizedBox(height:9),
          Text(card.title,style:const TextStyle(color:RoyalTheme.gold,
            fontSize:21,fontWeight:FontWeight.w900)),
          const SizedBox(height:9),
          Text(card.instructions,textAlign:TextAlign.center,
            style:const TextStyle(fontSize:13)),
          if(state.settings.mode==GameMode.shahGol)...[
            const SizedBox(height:12),
            const Text('هزینه میلی را از روی دفترچه اصلی مشخص کنید.'),
            ValueListenableBuilder<int>(valueListenable:cost,builder:(context,value,_)=>Row(
              mainAxisAlignment:MainAxisAlignment.center,children:[
                IconButton(onPressed:value>0?()=>cost.value=value-1:null,
                  icon:const Icon(Icons.remove_circle_outline)),
                Text('$value / $available',style:const TextStyle(
                  color:RoyalTheme.gold,fontWeight:FontWeight.bold)),
                IconButton(onPressed:value<available?()=>cost.value=value+1:null,
                  icon:const Icon(Icons.add_circle_outline)),
              ])),
          ],
          const SizedBox(height:17),
          FilledButton(onPressed:state.offensiveUsed?null:(){
            cubit.manualUseCard(id,milliCost:cost.value);
            Navigator.pop(modal);
          },child:const Text('کارت را مصرف کن')),
          const SizedBox(height:8),
        ])))).whenComplete(cost.dispose);
  }
}
