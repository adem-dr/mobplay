class AdkarItem {
  final String id;
  final String arabic;
  final String translation;
  final String transliteration;
  final int countTarget;
  final String source;

  const AdkarItem({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.transliteration,
    required this.countTarget,
    required this.source,
  });
}

class AdkarData {
  static const List<AdkarItem> sabah = [
    AdkarItem(
      id: "sabah_1",
      arabic: "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...",
      transliteration: "Allahu la ilaha illa Huwal-Hayyul-Qayyum...",
      translation: "Allah ! Point de divinité à part Lui, le Vivant, Celui qui subsiste par Lui-même...",
      countTarget: 1,
      source: "Ayat Al-Kursi (Al-Baqarah 255)",
    ),
    AdkarItem(
      id: "sabah_2",
      arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ. قُلْ هُوَ اللَّهُ أَحَدٌ. اللَّهُ الصَّمَدُ. لَمْ يَلِدْ وَلَمْ يُولَدْ. وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ.",
      transliteration: "Qul Huwallahu Ahad...",
      translation: "Dis : Il est Allah, Unique. Allah, Le Seul à être imploré...",
      countTarget: 3,
      source: "Sourate Al-Ikhlas",
    ),
    AdkarItem(
      id: "sabah_3",
      arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ...",
      transliteration: "Asbahna wa asbahal-mulku lillah...",
      translation: "Nous sommes au matin et la royauté appartient à Allah...",
      countTarget: 1,
      source: "Rapporté par Muslim",
    ),
    AdkarItem(
      id: "sabah_4",
      arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ...",
      transliteration: "Allahumma anta Rabbi la ilaha illa Anta, khalaqtani...",
      translation: "O Allah, Tu es mon Seigneur, il n'y a de divinité que Toi...",
      countTarget: 1,
      source: "Le Maître des demandes de pardon (Sayyidul Istighfar)",
    ),
    AdkarItem(
      id: "sabah_5",
      arabic: "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ.",
      transliteration: "Ya Hayyu Ya Qayyumu bi-rahmatika astaghith...",
      translation: "O Vivant, O Subsistant par Toi-même, par Ta miséricorde j'implore Ton secours...",
      countTarget: 3,
      source: "Rapporté par Al-Hakim",
    ),
  ];

  static const List<AdkarItem> massa = [
    AdkarItem(
      id: "massa_1",
      arabic: "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...",
      transliteration: "Allahu la ilaha illa Huwal-Hayyul-Qayyum...",
      translation: "Allah ! Point de divinité à part Lui, le Vivant, Celui qui subsiste par Lui-même...",
      countTarget: 1,
      source: "Ayat Al-Kursi (Al-Baqarah 255)",
    ),
    AdkarItem(
      id: "massa_2",
      arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ. قُلْ هُوَ اللَّهُ أَحَدٌ. اللَّهُ الصَّمَدُ...",
      transliteration: "Qul Huwallahu Ahad...",
      translation: "Dis : Il est Allah, Unique. Allah, Le Seul à être imploré...",
      countTarget: 3,
      source: "Sourate Al-Ikhlas",
    ),
    AdkarItem(
      id: "massa_3",
      arabic: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ...",
      transliteration: "Amsayna wa amsal-mulku lillah...",
      translation: "Nous sommes au soir et la royauté appartient à Allah...",
      countTarget: 1,
      source: "Rapporté par Muslim",
    ),
    AdkarItem(
      id: "massa_4",
      arabic: "اللَّهُمَّ عافِني في بَدَني، اللَّهُمَّ عافِني في سَمْعي، اللَّهُمَّ عافِني في بَصَري، لا إلهَ إلاَّ أَنْتَ.",
      transliteration: "Allahumma 'afini fi badani...",
      translation: "O Allah, préserve-moi dans mon corps. O Allah, préserve-moi dans mon ouïe...",
      countTarget: 3,
      source: "Rapporté par Abu Dawud",
    ),
  ];

  static const List<AdkarItem> layl = [
    AdkarItem(
      id: "layl_1",
      arabic: "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا...",
      transliteration: "Bismika Rabbi wada'tu janbi...",
      translation: "En Ton nom, mon Seigneur, je me couche, et par Toi je me relève...",
      countTarget: 1,
      source: "Rapporté par Al-Bukhari",
    ),
    AdkarItem(
      id: "layl_2",
      arabic: "اللَّهُمَّ خَلَقْتَ نَفْسِي وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا...",
      transliteration: "Allahumma khalaqta nafsi...",
      translation: "O Allah, Tu as créé mon âme et c'est Toi qui la reprends...",
      countTarget: 1,
      source: "Rapporté par Muslim",
    ),
    AdkarItem(
      id: "layl_3",
      arabic: "اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.",
      transliteration: "Allahumma qini 'adhabaka...",
      translation: "O Allah, préserve-moi de Ton châtiment le jour où Tu ressusciteras Tes serviteurs.",
      countTarget: 3,
      source: "Rapporté par Abu Dawud",
    ),
  ];
}
