from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import uvicorn

# START to FastAPI: 
app = FastAPI(
    title="Aegis-DLP Core API",
    description="Autonomous Agent-Based Middleware for Data Loss Prevention (DLP)",
    version="0.1.0"
)

# define the structure (schema) of the incoming request data.
class PromptRequest(BaseModel):
    user_id: str = Field(..., description=" (User ID Örn: emp_4521)")
    prompt: str = Field(..., description="The raw text to be sent to the LLM")

# define the structure of the returning response
class PromptResponse(BaseModel):
    original_prompt: str
    sanitized_prompt: str
    is_secure: bool
    status: str

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "Aegis-DLP Backend"}

@app.post("/chat", response_model=PromptResponse)
async def process_prompt(payload: PromptRequest):
    try:
        ham_prompt = payload.prompt
        temiz_prompt = ham_prompt
        guvenli_mi = True
        
        # Basit bir PoC (Konsept Kanıtı) maskeleme testi
        if "1234" in ham_prompt:
            temiz_prompt = ham_prompt.replace("1234", "[REDACTED_CREDIT_CARD]")
            guvenli_mi = False

        return PromptResponse(
            original_prompt=ham_prompt,
            sanitized_prompt=temiz_prompt,
            is_secure=guvenli_mi,
            status="Processed successfully"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main.py:app", host="127.0.0.1", port=8000, reload=True)