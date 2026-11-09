import 'package:flutter/material.dart';
import '../../core/theme/royal_theme.dart';
import '../../core/widgets/royal_widgets.dart';
import '../match/domain/match_rules.dart';
import '../match/domain/physical_cards.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key,this.mode});
  final GameMode? mode;
  @override Widget build(BuildContext context)=>RoyalScaffold(
    appBar:AppBar(title:const Text('آموزش و قوانین')),
    child:ListView(padding:const EdgeInsets.fromLTRB(18,68,18,32),children:[
      if(mode==null)...[
        const Center(child:CrownArt(size:86)),
        const SizedBox(height:16),
        const Text('قانون هر میدان را بشناس',textAlign:TextAlign.center,
          style:TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
        const SizedBox(height:18),
      ],
      for(final m in GameMode.values)
        if(mode==null || mode==m)...[
          const SizedBox(height:12),
          RoyalPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(m.title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:RoyalTheme.paleGold)),
            const SizedBox(height:9),
            Text(m.subtitle,style:const TextStyle(color:RoyalTheme.muted)),
            const RoyalDivider(),
            const _Step('۱. آماده‌سازی','دو تیم نام‌گذاری می‌شوند، امتیاز هدف بین ۸ تا ۳۱ است و شاه‌گل قابل خاموش یا روشن کردن است.'),
            const _Step('۲. نوبت بازی','یک تیم گل واقعی را در مشت‌های بسته پنهان می‌کند و تیم مقابل حدس می‌زند. تلفن فقط داور است.'),
            if(m==GameMode.nabardGol)...[
              const _Step('۳. امتیازها','تک‌ضرب ۲ امتیاز؛ گرفتن معمولی گل بدون امتیاز؛ حفظ گل یک امتیاز.'),
              const _Step('۴. سه خالی','سه خالی‌بازی مجاز است؛ سپس نوبت انتخاب نهایی گل است. پایان تایمر نیز یک انتخاب نهایی دارد.'),
              const _Step('۵. کارت‌ها','هر تیم ۵ کارت هجومی و ۲ خنثی‌کننده دارد. هر کارت فقط یک بار در مسابقه استفاده می‌شود و هر تیم در هر دست حداکثر یک کارت می‌سوزاند.'),
              for(final power in CardPower.values)_Step(power.title,power.description),
              const _Step('۶. شاه‌گل — بهای تاج','با رسیدن صاحب گل به امتیاز هدف منهای یک، شاه‌گل شروع می‌شود. حفظ گل مساوی قهرمانی است. شکست یعنی انتخاب عقب‌نشینی با ۳ امتیاز جریمه یا یک دوئل کاپیتان‌ها. شکست در دوئل ۵ امتیاز جریمه دارد. کارت در دوئل ممنوع است.'),
            ] else if(m==GameMode.filimo)...[
              const _Step('قانون امتیاز','با تک‌ضرب ۲ امتیاز می‌گیری، گرفتن معمولی گل امتیاز ندارد و حفظ گل برای تیم نگهدارنده یک امتیاز دارد.'),
              const _Step('خالی‌بازی و کارت','تا سه خالی‌بازی مجاز است؛ در هر دست حداکثر یک کارت و وقتی حداقل سه مشت بسته مانده باشد.'),
              const _Step('چینش پنج کارت','از دوئل/آنتن یک کارت، از گوی بزرگ/گوی صدادار یک کارت و از پنج کارت میانی سه کارت انتخاب می‌شود.'),
              const _Step('مکعب امتیازافزا','در فیلیمو، مکعب یک تنظیم مستقل و اختیاری دارد؛ اگر روشن باشد، امتیاز مکعب را داور طبق نسخه واقعی وارد می‌کند.'),
              for(final id in const ['antenna','duel','largeSphere','soundSphere',
                'doubleSight','extraEmpty','eliminateFist','sparrow1'])
                _Step(PhysicalCards.all[id]!.title,PhysicalCards.all[id]!.instructions),
              const _Step('شاه‌گل فیلیمو','در شاه‌گل کارت‌ها قابل استفاده نیستند. طبق توضیحات عمومی نسخه مسابقه‌ای، شش خالی باز می‌شود و پوچ‌کردن عادی وجود ندارد. در شکست اول شاه‌گل سه امتیاز کسر می‌شود؛ شکست بعدی نتیجه را به دوئل می‌برد.'),
              const _Step('ثبت دستی داور','محاسبه جزئیات اختلاف نسخه‌ها و بعضی کارت‌ها تا تأیید دفترچه رسمی به عهده داور است. کارت مصرف‌شده و امتیاز در برنامه ثبت می‌شود.'),
            ] else ...[
              const _Step('مکعب میلی','مکعب بخشی جدایی‌ناپذیر از نسخه رومیزی شاه‌گل است و گزینه حذف ندارد.'),
              const _Step('موجودی میلی','با اجرای مکعب در بازی واقعی، مقدار میلی هر تیم را با کنترل‌های روی صفحه ثبت کنید. برای مصرف کارت، مقدار هزینه را طبق دفترچه وارد کنید.'),
              for(final id in const ['shahKesh','nazeshast','roodast','bakhtak','taftish'])
                _Step(PhysicalCards.all[id]!.title,PhysicalCards.all[id]!.instructions),
              const _Step('داوری قوانین اصلی','جزئیات کارت‌ها و نحوه تعیین نتیجه شاه‌گل باید با دفترچه رسمی تأیید شوند؛ برنامه اطلاعات ثبت‌شده را ذخیره می‌کند و قاعده نادرست نمی‌سازد.'),
            ],
          ])),
        ],
      const SizedBox(height:20),
      const Text('تنظیمات امتیاز و شاه‌گل در هر سه حالت یکسان است؛ قوانین کارت‌ها مستقل هستند.',
        textAlign:TextAlign.center,style:TextStyle(fontSize:12,color:RoyalTheme.muted)),
    ]),
  );
}
class _Step extends StatelessWidget {
  const _Step(this.title,this.body);
  final String title,body;
  @override Widget build(BuildContext context)=>Padding(
    padding:const EdgeInsets.symmetric(vertical:9),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:RoyalTheme.gold)),
      const SizedBox(height:5),
      Text(body,style:const TextStyle(height:1.65,fontSize:13)),
    ]));
}
