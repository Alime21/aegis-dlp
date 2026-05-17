from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import uvicorn
from services.dlp_service import dlp_agent

# START to FastAPI: 
app = FastAPI(
    title="Aegis-DLP Core API",
    description="Autonomous Agent-Based Middleware for Data Loss Prevention (DLP)",
    version="0.2.0"
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
    detected_entities: list

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "Aegis-DLP Backend"}

@app.post("/chat", response_model=PromptResponse)
async def process_prompt(payload: PromptRequest):
    try:
        ham_prompt = payload.prompt

        analiz_sonucu = dlp_agent.sanitize_text(ham_prompt)

        return PromptResponse(
            original_prompt=ham_prompt,
            sanitized_prompt=analiz_sonucu["sanitized_text"],
            is_secure=analiz_sonucu["is_secure"],
            detected_entities=analiz_sonucu["detected_entities"],
            status="Processed via Presidio AI"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main.py:app", host="127.0.0.1", port=8000, reload=True)