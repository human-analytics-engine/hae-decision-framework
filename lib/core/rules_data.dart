// lib/core/rules_data.dart
import '../models/rule_model.dart';

class RulesData {
  static List<RuleModel> get universalRules => [
    // --- AŞAMA 1: ZİHNİ TEMİZLE ---
    RuleModel(
      id: 1,
      stage: Stage.clearMind,
      title: "🛑 Geri Dönüş Çizgisi",
      concept: "Pre-commitment (Önceden Taahhüt)",
      description: "Sonucu görmeden önce, ne olursa bu işi derhal bırakacağını yaz.",
      defaultQuestion: "Bu kararın başarısız olduğunu ne zaman kabul edeceksin? Net, ölçülebilir bir 'Vazgeçme / Stop-Loss' sınırı belirledin mi?",
    ),
    RuleModel(
      id: 2,
      stage: Stage.clearMind,
      title: "📊 Dünya Gerçeği (İstatistik)",
      concept: "Base Rate (Temel Oran)",
      description: "Senin durumun mucize değil. Dünyada bu işe girenlerin kaçı battı?",
      defaultQuestion: "Kendi özel yeteneğine aşık olmadan önce, dünyada benzer kararı alanların genel hayatta kalma oranını dürüstçe araştırdın mı?",
    ),
    
    // --- AŞAMA 2: GERÇEKLİKLE YÜZLEŞ ---
    RuleModel(
      id: 3,
      stage: Stage.testReality,
      title: "🗡️ Fikri Katletme Testi",
      concept: "Red-Teaming (Yanlışlama Arayışı)",
      description: "Fikrini kanıtlamaya çalışma; en sert düşmanın gibi saldırıp çürüt.",
      defaultQuestion: "Bu fikrin 'kesinlikle batacağı' bir senaryoyu tüm çıplaklığıyla yazıp kendi inancını aktif olarak çürütmeyi denedin mi?",
    ),
    RuleModel(
      id: 4,
      stage: Stage.testReality,
      title: "🕶️ Tarafsız Hakem",
      concept: "Blind Validation (Dokunulmamış Veri)",
      description: "Fikrini, senin başarılı olmandan hiçbir çıkarı olmayan birine test ettir.",
      defaultQuestion: "Bu planı; seni sevmeyen, sırtını sıvazlamayacak ve başarından nemalanmayacak tarafsız bir göze/veriye incelettin mi?",
    ),
    RuleModel(
      id: 5,
      stage: Stage.testReality,
      title: "🎲 Şans mı, Ustalık mı?",
      concept: "Multiple Testing Penalty (Çoklu Deneme Cezası)",
      description: "100 kere zar attıktan sonra gelen 6'yı 'büyük deha' sanma.",
      defaultQuestion: "Bu fikri bulana kadar kaç başarısız yol denedin? Şu anki heyecanının sadece şans veya tesadüf olma ihtimalini cezalandırdın mı?",
    ),
    RuleModel(
      id: 6,
      stage: Stage.testReality,
      title: "🗣️ Kahvehane Hikayesi Tuzağı",
      concept: "Anecdotal Fallacy (Anekdotu Reddet)",
      description: "'Bir arkadaş köşeyi döndü' lafı kanıt değil, masaldır.",
      defaultQuestion: "Bu kararı sadece canlı ve ilham verici birkaç başarı hikayesine dayanarak mı, yoksa sistematik veriye dayanarak mı alıyorsun?",
    ),
    RuleModel(
      id: 7,
      stage: Stage.testReality,
      title: "⚙️ Dişli Çarklar Testi",
      concept: "Causal Mechanism (Nedensel Mekanizma)",
      description: "A ile B birlikte artıyor diye biri diğerinin sebebi olmak zorunda değil.",
      defaultQuestion: "Beklediğin sonucun tam olarak hangi somut, mantıksal veya fiziksel mekanizma ile gerçekleşeceğini adım adım açıklayabiliyor musun?",
    ),

    // --- AŞAMA 3: KORUNMA & HAYATTA KALMA ---
    RuleModel(
      id: 8,
      stage: Stage.survival,
      title: "🪂 Yedek Paraşüt",
      concept: "Margin of Safety (Güvenlik Marjı)",
      description: "İşler 2 kat daha pahalı ve 3 kat daha yavaş biterse hayatta kalır mısın?",
      defaultQuestion: "Tüm hesapların doğru olsa bile, öngöremediğin felaketler (siyah kuğular) için kenarda sağlam bir bütçe ve zaman toleransı bıraktın mı?",
    ),
    RuleModel(
      id: 9,
      stage: Stage.survival,
      title: "🩸 Bedel Ödeme Kuralı",
      concept: "Skin in the Game (Oyunda Derisi Olmak)",
      description: "Tavsiye veren kişi işler batarsa 1 kuruş kaybedecek mi?",
      defaultQuestion: "Seni bu karara teşvik eden veya akıl veren kişilerin, işler ters gittiğinde kaybedecekleri gerçek bir şey (para, itibar) var mı?",
    ),
    RuleModel(
      id: 10,
      stage: Stage.survival,
      title: "⏰ Son Kullanma Tarihi",
      concept: "Alpha Decay / Longitudinal Tracking (Zamanla İzleme)",
      description: "Bugün süper çalışan bir fikir, 6 ay sonra kabak çiçeği gibi sönebilir.",
      defaultQuestion: "Bu kararı aldıktan sonra, fikrin geçerliliğini yitirip yitirmediğini düzenli olarak denetleyecek bir alarm sistemi kurdun mu?",
    ),
  ];
}