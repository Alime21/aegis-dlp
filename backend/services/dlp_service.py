from presidio_analyzer import AnalyzerEngine, PatternRecognizer, Pattern
from presidio_analyzer.nlp_engine import NlpEngineProvider
from presidio_anonymizer import AnonymizerEngine

# 1. NLP Motoru Yapılandırması: İngilizce ve Türkçe (Çok Dilli) Modelleri Tanıtıyoruz
configuration = {
    "nlp_engine_name": "spacy",
    "models": [
        {"lang_code": "tr", "model_name": "xx_ent_wiki_sm"}, # Türkçe için çok dilli model
        {"lang_code": "en", "model_name": "en_core_web_lg"}, # İngilizce için geniş model
    ],
}

# 2. Motoru oluşturuyoruz
provider = NlpEngineProvider(nlp_configuration=configuration)
nlp_engine = provider.create_engine()


class DLPService:
    def __init__(self):
        # initialize agents with the bilingual NLP engine
        self.analyzer = AnalyzerEngine(nlp_engine=nlp_engine)
        self.anonymizer = AnonymizerEngine()

        sifre_deseni = Pattern(
            name="sifre_yakalayici", 
            regex=r"(?i)(?:şifr\w*|password|parola\w*)(?:\s*[:=]\s*|\s+)(\S+)", 
            score=0.9
        )
        sifre_tanimlayici = PatternRecognizer(
            supported_entity="PASSWORD", 
            patterns=[sifre_deseni]
        )
        self.analyzer.registry.add_recognizer(sifre_tanimlayici)

    def sanitize_text(self, text: str) -> dict:
        """
        Scans incoming text, detects and masks sensitive data in both Turkish and English.
        """
        # 1. select which assets to search for (Name, Credit Card, Location, Password)
        target_entities = ["PERSON", "CREDIT_CARD", "LOCATION", "PASSWORD"]

        # 2. Analysis Phase: Find the locations of sensitive data in both languages
        results_tr = self.analyzer.analyze(
            text=text, 
            entities=target_entities, 
            language='tr',
            score_threshold=0.60
        )
        
        results_en = self.analyzer.analyze(
            text=text, 
            entities=target_entities, 
            language='en',
            score_threshold=0.60
        )

        # İki dilden gelen sonuçları birleştir
        all_results = results_tr + results_en

        # 3. Masking Phase: Replace found data with [MASKED] (or <ENTITY_TYPE>)
        anonymized_result = self.anonymizer.anonymize(
            text=text,
            analyzer_results=all_results
        )

        # --- DE-ANONYMIZE Dictionary --- #
        entity_mapping = {}
        for res in all_results:
            orijinal_deger = text[res.start:res.end]
            etiket = f"<{res.entity_type}>"

            if etiket not in entity_mapping:
                entity_mapping[etiket] = orijinal_deger

        is_secure = len(all_results) == 0

        # İki dilde de aynı şeyi bulursa listeyi temiz tutmak için 'set' kullanıyoruz
        unique_detected_entities = list(set([res.entity_type for res in all_results]))

        return {
            "sanitized_text": anonymized_result.text,
            "is_secure": is_secure,
            "detected_entities": unique_detected_entities,
            "entity_mapping": entity_mapping
        }
    
    def deanonymize_text(self, text: str, mapping: dict) -> str:
        """
        It converts the masked response from the LLM back to its original form using the dictionary in memory.
        """
        for etiket, orijinal_deger in mapping.items():
            text = text.replace(etiket, orijinal_deger)
        return text


# To use the service throughout the project, we create an instance (copy) of it.
dlp_agent = DLPService()