import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/royal_theme.dart';
import '../../core/widgets/royal_widgets.dart';
import '../match/domain/match_rules.dart';
import '../match/domain/physical_cards.dart';

class CatalogEntry {
  const CatalogEntry(this.title, this.asset, this.description, {this.verified = true});
  final String title;
  final String asset;
  final String description;
  final bool verified;
}

class CardGalleryCubit extends Cubit<GameMode> {
  CardGalleryCubit() : super(GameMode.nabardGol);
  void change(GameMode value) => emit(value);
}

class CardGalleryPage extends StatelessWidget {
  const CardGalleryPage({super.key});
  @override Widget build(BuildContext context) => BlocProvider(
    create: (_) => CardGalleryCubit(), child: const _CardGalleryBody());
}

class _CardGalleryBody extends StatelessWidget {
  const _CardGalleryBody();
  static List<CatalogEntry> cards(GameMode mode) => switch (mode) {
    GameMode.nabardGol => [
      for (final card in CardPower.values)
        CatalogEntry(card.title, card.asset, card.description),
      const CatalogEntry('خنثی‌کننده','assets/cards/nullifier.svg',
        'کارت هجومی حریف را لغو می‌کند؛ هر تیم دو کارت برای تمام مسابقه دارد.'),
      const CatalogEntry('پشت کارت','assets/cards/back.svg',
        'طرح یکپارچه پشت کارت‌های اختصاصی.'),
    ],
    GameMode.filimo => [
      for(final id in const ['antenna','duel','largeSphere','soundSphere',
        'doubleSight','extraEmpty','eliminateFist','sparrow1','sparrow2'])
        CatalogEntry(PhysicalCards.all[id]!.title,PhysicalCards.all[id]!.asset,
          PhysicalCards.all[id]!.instructions,verified:true),
      const CatalogEntry('مکعب امتیازافزا','assets/cards/cube.svg',
        'در تنظیمات فیلیمو می‌توان مکعب را فعال یا غیرفعال کرد.'),
    ],
    GameMode.shahGol => [
      const CatalogEntry('شاه‌کش','assets/cards/shah_shahkesh.svg',
        'کارت رسمی نسخه رومیزی؛ جزئیات هزینه میلی و اثر مطابق دفترچه.',verified:false),
      const CatalogEntry('نازشست','assets/cards/shah_nazeshost.svg',
        'کارت ویژه نسخه رومیزی؛ جزئیات اثر مطابق دفترچه.',verified:false),
      const CatalogEntry('رو دست','assets/cards/shah_roodast.svg',
        'کارت ویژه نسخه رومیزی؛ جزئیات اثر مطابق دفترچه.',verified:false),
      const CatalogEntry('بختک','assets/cards/shah_bakhtak.svg',
        'کارت ویژه نسخه رومیزی؛ جزئیات اثر مطابق دفترچه.',verified:false),
      const CatalogEntry('تفتیش','assets/cards/shah_taftish.svg',
        'کارت ویژه نسخه رومیزی؛ جزئیات اثر مطابق دفترچه.',verified:false),
      const CatalogEntry('مکعب میلی','assets/cards/cube.svg',
        'مکعب برای کسب میلی مورد نیاز کارت‌ها، جزئی از قوانین اصلی و غیرقابل حذف است.'),
    ]
  };

  @override Widget build(BuildContext context) => BlocBuilder<CardGalleryCubit,GameMode>(
    builder: (context,mode) {
      final list = cards(mode);
      return RoyalScaffold(
        appBar: AppBar(title: const Text('تالار کارت‌های شاهانه')),
        child: ListView(padding: const EdgeInsets.fromLTRB(17,70,17,32), children: [
          const Center(child: CrownArt(size:77)),
          const SizedBox(height:8),
          const Text('مجموعه کارت‌های اختصاصی',
            textAlign: TextAlign.center, style: TextStyle(
              fontWeight: FontWeight.w900,fontSize:22,color:RoyalTheme.paleGold)),
          const SizedBox(height:17),
          Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children: [
            for(final m in GameMode.values) ChoiceChip(
              label: Text(m.title),
              selected:m==mode,
              onSelected:(_)=>context.read<CardGalleryCubit>().change(m)),
          ]),
          const SizedBox(height:14),
          if(mode!=GameMode.nabardGol)
            const RoyalPanel(child: Text(
              'این تصویرسازی‌ها اورجینال هستند؛ شرح قوانین کارت‌های دو نسخه مرجع '
              'تا دریافت دفترچه کامل در حالت راهنمای تصویری باقی می‌ماند.',
              style:TextStyle(color:RoyalTheme.muted,fontSize:12),textAlign:TextAlign.center)),
          const SizedBox(height:18),
          GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
            itemCount:list.length,
            gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:2,childAspectRatio:.62,crossAxisSpacing:12,mainAxisSpacing:12),
            itemBuilder:(context,index){
              final card=list[index];
              return InkWell(
                borderRadius:BorderRadius.circular(20),
                onTap:()=>_showCard(context,card),
                child: RoyalPanel(padding:const EdgeInsets.all(9),child:Column(children:[
                  Expanded(child:SvgPicture.asset(card.asset,fit:BoxFit.contain)),
                  const SizedBox(height:9),
                  Text(card.title,textAlign:TextAlign.center,
                    style:const TextStyle(fontWeight:FontWeight.w800,fontSize:13)),
                ])),
              );
            }),
        ]),
      );
    },
  );

  void _showCard(BuildContext context,CatalogEntry entry) {
    showModalBottomSheet<void>(context:context,
      showDragHandle:true,isScrollControlled:true,
      backgroundColor:RoyalTheme.ink,
      builder:(modal)=>SafeArea(child:Padding(
        padding:const EdgeInsets.fromLTRB(20,10,20,20),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          SizedBox(height:280,child:SvgPicture.asset(entry.asset)),
          const SizedBox(height:14),
          Text(entry.title,style:const TextStyle(
            fontSize:23,fontWeight:FontWeight.w900,color:RoyalTheme.gold)),
          const SizedBox(height:10),
          Text(entry.description,textAlign:TextAlign.center),
          if(!entry.verified)...[
            const SizedBox(height:8),
            const Text('جزئیات این کارت هنوز از دفترچه رسمی تأیید نشده است.',
              textAlign:TextAlign.center,
              style:TextStyle(color:RoyalTheme.muted,fontSize:11)),
          ],
          const SizedBox(height:17),
          FilledButton(onPressed:()=>Navigator.pop(modal),
            child:const Text('متوجه شدم')),
        ]))),
    );
  }
}
