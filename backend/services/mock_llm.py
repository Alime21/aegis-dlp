import asyncio

class MockLLMService:
    async def generate_response(self, text: str) -> str:
        """
         It receives the masked prompt and responds as if it were OpenAI.
         It thinks for 1 second and returns a logical answer.
        """
        # Gerçek bir LLM gibi 1 saniye düşünme süresi simülasyonu
        await asyncio.sleep(1)
        
        if not text:
            return "Boş metin gönderildi."
        
        # Güvenlik politikası uyarısı (şifre vs. varsa)
        if "<PASSWORD>" in text:
            return f"Due to security policies, I cannot verify your password ({text}) in plain text in our systems."
        
        # Standart cevap
        return f"İşleminiz şu metin üzerinden başarıyla gerçekleştirildi: {text}"
        
mock_llm = MockLLMService()