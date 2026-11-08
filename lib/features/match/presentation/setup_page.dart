import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/royal_theme.dart';
import '../../../core/widgets/royal_widgets.dart';
import '../../guide/guide_page.dart';
import '../domain/match_rules.dart';
import '../domain/match_state.dart';
import 'match_page.dart';

class SetupValue {
  const SetupValue({this.target=21, this.shah=true, this.cube=true, this.seconds=90, this.players=3, this.holder=0});
  final int target, seconds, players, holder;
  final bool shah, cube;
  SetupValue copy({int? target, bool? shah, bool? cube, int? seconds, int? players, int? holder}) =>
    SetupValue(target: target ?? this.target, shah: shah ?? this.shah,
      cube: cube ?? this.cube, seconds: seconds ?? this.seconds,
      players: players ?? this.players, holder: holder ?? this.holder);
}
class SetupCubit extends Cubit<SetupValue> {
  SetupCubit(): super(const SetupValue());
  void setTarget(int v)=>emit(state.copy(target:v));
  void setShah(bool v)=>emit(state.copy(shah:v));
  void setCube(bool v)=>emit(state.copy(cube:v));
  void setSeconds(int v)=>emit(state.copy(seconds:v));
  void setPlayers(int v)=>emit(state.copy(players:v));
  void setHolder(int v)=>emit(state.copy(holder:v));
}

class SetupPage extends StatelessWidget {
  const SetupPage({super.key, required this.mode});
  final GameMode mode;
  @override Widget build(BuildContext context) => BlocProvider(
    create: (_) => SetupCubit(), child: _SetupBody(mode: mode));
}

class _SetupBody extends StatefulWidget {
  const _SetupBody({required this.mode});
  final GameMode mode;
  @override State<_SetupBody> createState()=>_SetupBodyState();
}

class _SetupBodyState extends State<_SetupBody> {
  final a=TextEditingController(text:'تیم طلایی');
  final b=TextEditingController(text:'تیم یاقوت');
  @override void dispose(){a.dispose();b.dispose();super.dispose();}
  @override Widget build(BuildContext context) {
    final cubit=context.read<SetupCubit>();
    return RoyalScaffold(
      appBar: AppBar(title: Text('آماده‌سازی • ${widget.mode.title}'),
        actions: [IconButton(tooltip:'آموزش',icon:const Icon(Icons.help_outline),
          onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>GuidePage(mode:widget.mode))))]),
      child: BlocBuilder<SetupCubit,SetupValue>(builder:(context,s)=>ListView(
        padding:const EdgeInsets.fromLTRB(20,68,20,32),children:[
        const Center(child:CrownArt(size:86)),
        const SizedBox(height:5),
        Text(widget.mode.title,textAlign:TextAlign.center,style:const TextStyle(
          color:RoyalTheme.paleGold,fontWeight:FontWeight.w900,fontSize:27)),
        const SizedBox(height:20),
        const RoyalSectionTitle('تیم‌های مسابقه'),
        RoyalPanel(child:Column(children:[
          TextField(controller:a,maxLength:22,decoration:const InputDecoration(
            labelText:'تیم اول',prefixIcon:Icon(Icons.groups_outlined))),
          const SizedBox(height:10),
          TextField(controller:b,maxLength:22,decoration:const InputDecoration(
            labelText:'تیم دوم',prefixIcon:Icon(Icons.groups_outlined))),
        ])),
        const SizedBox(height:16),
        RoyalPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            const Text('امتیاز هدف',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
            Text('${s.target}',style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900,color:RoyalTheme.gold)),
          ]),
          Slider(value:s.target.toDouble(),min:8,max:31,divisions:23,
            label:'${s.target}',onChanged:(v)=>cubit.setTarget(v.round())),
          const Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            Text('۸',style:TextStyle(color:RoyalTheme.muted)),Text('۳۱',style:TextStyle(color:RoyalTheme.muted))]),
          const RoyalDivider(),
          SwitchListTile.adaptive(contentPadding:EdgeInsets.zero,value:s.shah,
            onChanged:cubit.setShah,title:const Text('شاه‌گل'),
            subtitle:Text(s.shah?'مرحله پایانی در امتیاز ${s.target-1}':'برد مستقیم در امتیاز ${s.target}')),
          if(widget.mode==GameMode.filimo)
            SwitchListTile.adaptive(contentPadding:EdgeInsets.zero,value:s.cube,
              onChanged:cubit.setCube,title:const Text('مکعب امتیازافزا'),
              subtitle:const Text('فقط در حالت فیلیمو • اختیاری')),
          if(widget.mode==GameMode.shahGol)
            const ListTile(contentPadding:EdgeInsets.zero,
              leading:Icon(Icons.casino,color:RoyalTheme.gold),
              title:Text('مکعب میلی'),subtitle:Text('در نسخه اصلی، مکعب همیشه جزئی از قوانین است')),
        ])),
        const SizedBox(height:16),
        RoyalPanel(child:Column(children:[
          Row(children:[const Expanded(child:Text('زمان هر دست')),
            Text('${s.seconds} ثانیه',style:const TextStyle(color:RoyalTheme.gold,fontWeight:FontWeight.bold))]),
          Slider(min:30,max:180,divisions:10,value:s.seconds.toDouble(),
            onChanged:(v)=>cubit.setSeconds(v.round())),
          const SizedBox(height:14),
          Row(children:[const Expanded(child:Text('بازیکن در هر تیم')),
            Text('${s.players}',style:const TextStyle(color:RoyalTheme.gold,fontWeight:FontWeight.bold))]),
          Slider(min:1,max:8,divisions:7,value:s.players.toDouble(),
            onChanged:(v)=>cubit.setPlayers(v.round())),
          const SizedBox(height:12),
          const Text('تیمی که اول گل را مخفی می‌کند',style:TextStyle(color:RoyalTheme.muted)),
          SegmentedButton<int>(showSelectedIcon:false,
            segments:[const ButtonSegment(value:0,label:Text('تیم اول')),
              const ButtonSegment(value:1,label:Text('تیم دوم'))],
            selected:{s.holder},onSelectionChanged:(v)=>cubit.setHolder(v.first)),
        ])),
        const SizedBox(height:20),
        FilledButton.icon(onPressed:(){
          final nameA=a.text.trim().isEmpty?'تیم اول':a.text.trim();
          final nameB=b.text.trim().isEmpty?'تیم دوم':b.text.trim();
          final settings=MatchSettings(mode:widget.mode,target:s.target,
            shahGolEnabled:s.shah,filimoCubeEnabled:s.cube,
            turnSeconds:s.seconds,playersPerTeam:s.players);
          final match=MatchState.start(settings,nameA,nameB,holder:s.holder);
          Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>MatchPage(initial:match)));
        },icon:const Icon(Icons.play_arrow_rounded),label:const Text('ورود به میدان مسابقه')),
        const SizedBox(height:12),
        TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(
          builder:(_)=>GuidePage(mode:widget.mode))),
          icon:const Icon(Icons.menu_book),label:const Text('آموزش این حالت بازی')),
      ])),
    );
  }
}
