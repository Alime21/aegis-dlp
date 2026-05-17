import asyncio

class MockLLMService:
    async def generate_response(self, prompt: str) -> str:
        """
         It receives the masked prompt and responds as if it were OpenAI.
         It thinks for 1 second and returns a logical answer.
        """
        await asyncio.sleep(1)
        if "<CREDIT_CARD>" in prompt:
            return f"I have initiated your transaction for the card numbered <CREDIT_CARD> that you specified in the system. Do you have any other requests, <PERSON>?"
        elif "<PASSWORD>" in prompt:
            return "Due to security policies, I cannot verify your password (<PASSWORD>) in plain text in our systems."
            return "Your request has been received. How can I help you?"

mock_llm = MockLLMService()