from presidio_analyzer import AnalyzerEngine, PatternRecognizer, Pattern
from presidio_anonymizer import AnonymizerEngine

class DLPService:
    def __init__(self):
        # initialize agents only once when the class is called (for memory management)
        self.analyzer = AnalyzerEngine()
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
        Scans incoming text, detects and masks sensitive data.
        """
        # 1. select which assets to search for (Name, Credit Card, Location)
        target_entities = ["PERSON", "CREDIT_CARD", "LOCATION","PASSWORD"]

        # 2. Analysis Phase: Find the locations of sensitive data in the text
        analyzer_results = self.analyzer.analyze(
            text=text, 
            entities=target_entities, 
            language='en',
            score_threshold=0.60
        )

       # 3. Masking Phase: Replace found data with [MASKED] (or <ENTITY_TYPE>)
        anonymized_result = self.anonymizer.anonymize(
            text=text,
            analyzer_results=analyzer_results
        )

        # --- DE-ANONYMIZE Dictionary --- #

        entity_mapping = {}
        for res in analyzer_results:
            orijinal_deger = text[res.start:res.end]
            etiket = f"<{res.entity_type}>"

            if etiket not in entity_mapping:
                entity_mapping[etiket] = orijinal_deger
                
            entity_mapping[etiket] = orijinal_deger

        is_secure = len(analyzer_results) == 0

        return {
            "sanitized_text": anonymized_result.text,
            "is_secure": is_secure,
            "detected_entities": [res.entity_type for res in analyzer_results],
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