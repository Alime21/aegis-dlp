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
            language='en'
        )

       # 3. Masking Phase: Replace found data with [MASKED] (or <ENTITY_TYPE>)
        anonymized_result = self.anonymizer.anonymize(
            text=text,
            analyzer_results=analyzer_results
        )

        # 4. Return the operation result (If masking was performed, is_secure becomes False)
        is_secure = len(analyzer_results) == 0

        return {
            "sanitized_text": anonymized_result.text,
            "is_secure": is_secure,
            "detected_entities": [res.entity_type for res in analyzer_results]
        }

# To use the service throughout the project, we create an instance (copy) of it.
dlp_agent = DLPService()    