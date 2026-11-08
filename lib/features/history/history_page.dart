import 'package:flutter/material.dart';
import '../../core/theme/royal_theme.dart';
import '../../core/widgets/royal_widgets.dart';
import '../match/data/match_store.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override Widget build(BuildContext context)=>RoyalScaffold(
    appBar:AppBar(title:const Text('تالار افتخارات')),
    child:FutureBuilder<List<Map<String,dynamic>>>(
      future:MatchStore().results(),
      builder:(context,snapshot){
        final entries=snapshot.data??[];
        if(entries.isEmpty)return const Center(child:Padding(
          padding:EdgeInsets.all(32),
          child:Column(mainAxisSize:MainAxisSize.min,children:[
            CrownArt(size:105),SizedBox(height:20),
            Text('هنوز قهرمانی ثبت نشده',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
            SizedBox(height:8),
            Text('بعد از پایان اولین مسابقه، نتیجه اینجا ذخیره می‌شود.',
              textAlign:TextAlign.center,style:TextStyle(color:RoyalTheme.muted)),
          ])));
        return ListView(padding:const EdgeInsets.fromLTRB(18,72,18,25),children:[
          for(final entry in entries)Padding(padding:const EdgeInsets.only(bottom:12),
            child:RoyalPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text((entry['mode']??'').toString(),style:const TextStyle(
                color:RoyalTheme.gold,fontWeight:FontWeight.bold)),
              const SizedBox(height:8),
              Text(((entry['teams'] as List)[(entry['winner'] as int?)??0]).toString(),
                style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
              const SizedBox(height:7),
              Text((entry['scores'] as List).join('  –  '),
                style:const TextStyle(color:RoyalTheme.muted)),
            ]))),
        ]);
      },
    ),
  );
}
