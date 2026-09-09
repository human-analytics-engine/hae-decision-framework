// lib/core/rules_data.dart

import '../models/rule_model.dart';

class RulesData {
  static List<RuleModel> get universalRules => [
    // --- AŞAMA 1: ZİHNİ TEMİZLE ---
    RuleModel(
      id: 1,
      stage: Stage.clearMind,
      title: "Önceden Taahhüt (Pre-commitment)",
      description: "Sonucu görmeden önce, neyi başarı sayacağını yazılı olarak sabitle.",
      question: "Bu kararın başarılı/başarısız sayılması için kesin, ölçülebilir ve zaman sınırlı bir kriteri 'önceden' belirleyip bir yere yazdın mı?",
    ),
    RuleModel(
      id: 2,
      stage: Stage.clearMind,
      title: "Dış Bakış (Base Rate)",
      description: "Kendi durumuna aşık olmadan önce sektörün genel başarı oranına bak.",
      question: "Senin durumuna benzeyen geçmiş girişimlerin/kararların genel istatistiksel başarı oranını (Base Rate) araştırdın mı?",
    ),
    
    // --- AŞAMA 2: GERÇEKLİKLE YÜZLEŞ ---
    RuleModel(
      id: 3,
      stage: Stage.testReality,
      title: "Yanlışlama Arayışı (Red-Teaming)",
      description: "Kendi fikrini kanıtlamaya değil, çürütmeye çalış.",
      question: "Bu fikrin 'kesinlikle batacağı' bir senaryo yazıp, kendi inancını aktif olarak çürütmeye (Red-Team) çalıştın mı?",
    ),
    RuleModel(
      id: 4,
      stage: Stage.testReality,
      title: "Dokunulmamış Veri (Blind Validation)",
      description: "Projeyi, fikrine aşık olmayan bağımsız bir göze test ettir.",
      question: "Bu kararı/fikri, umduğun sonucu bilmeyen ve senin başarılı olmandan bir çıkarı olmayan bağımsız birine veya sisteme test ettirdin mi?",
    ),
    RuleModel(
      id: 5,
      stage: Stage.testReality,
      title: "Çoklu Deneme Cezası",
      description: "Çok denediysen başarmış sayılmazsın, rastgelelik payını düş.",
      question: "Bu 'harika' fikri/paterni bulana kadar kaç farklı başarısız varyasyon denedin? Rastgelelik ihtimalini (p-hacking) hesaba kattın mı?",
    ),
    RuleModel(
      id: 6,
      stage: Stage.testReality,
      title: "Anekdotu Reddet",
      description: "2-3 parlak örnek kanıt değil hikayedir.",
      question: "Kararını sadece çok canlı hissettiren birkaç hikaye/örnek üzerine mi yoksa istatistiksel olarak anlamlı büyüklükte bir veri seti üzerine mi kuruyorsun?",
    ),
    RuleModel(
      id: 7,
      stage: Stage.testReality,
      title: "Nedensel Mekanizma",
      description: "Korelasyon yetmez, mantıklı bir nedensel model kur.",
      question: "A'nın B'ye yol açtığını düşünüyorsan, sadece rakamlara bakmak yerine aradaki mantıksal/fiziksel mekanizmayı tam olarak açıklayabiliyor musun?",
    ),

    // --- AŞAMA 3: KORUNMA ---
    RuleModel(
      id: 8,
      stage: Stage.survival,
      title: "Güvenlik Marjı (Margin of Safety)",
      description: "Bilinmeyenler için tolerans payı bırak.",
      question: "Her şeyi doğru hesaplamış olsan bile, öngörülemeyen sürprizler (siyah kuğular) için bir hata payı (bütçe, zaman, risk) bıraktın mı?",
    ),
    RuleModel(
      id: 9,
      stage: Stage.survival,
      title: "Oyunda Derisi Olmak (Skin in the Game)",
      description: "Tavsiye verenin yanıldığında bedel ödeyip ödemediğini test et.",
      question: "Bu kararı alırken güvendiğin kişilerin veya danışmanların, işler ters gittiğinde kaybedecekleri bir şey (Skin in the Game) var mı?",
    ),
    RuleModel(
      id: 10,
      stage: Stage.survival,
      title: "Zamanla İzleme",
      description: "Çalışan sistem zamanla çürür, sürekli ölç.",
      question: "Bu kararı verdikten sonra, sistemin bozulup bozulmadığını (Alpha Decay) düzenli olarak test edecek bir alarm/gözetim mekanizması kurdun mu?",
    ),
  ];
}