from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, Field
import uvicorn
from sqlalchemy.orm import Session
import traceback

# Services and database 
from services.dlp_service import dlp_agent
from services.mock_llm import mock_llm
from database import SessionLocal, AuditLog

# START to FastAPI: 
app = FastAPI(
    title="Aegis-DLP Core API",
    description="Autonomous Agent-Based Middleware for Data Loss Prevention (DLP)",
    version="1.0.0"
)

CURRENT_POLICIES = {
    "credit_card": True,
    "password": True,
    "tckn": True
}

# Database Session (Dependency Injection)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Data structure to hold the status of the rules      
class PolicyUpdateRequest(BaseModel):
    credit_card: bool
    password: bool
    tckn: bool

@app.get("/policies")
def get_policies():
    """iOS uygulamasının başlangıçta kuralların durumunu öğrenmesi için"""
    return CURRENT_POLICIES

@app.put("/policies")
def update_policies(payload: PolicyUpdateRequest):
    """iOS uygulamasındaki Toggle butonlarına basıldığında tetiklenecek uç"""
    global CURRENT_POLICIES
    CURRENT_POLICIES["credit_card"] = payload.credit_card
    CURRENT_POLICIES["password"] = payload.password
    CURRENT_POLICIES["tckn"] = payload.tckn
    
    print(f"KURAL GÜNCELLENDİ: {CURRENT_POLICIES}")
    return {"status": "updated", "policies": CURRENT_POLICIES}

# define the structure (schema) of the incoming request data.
class PromptRequest(BaseModel):
    user_id: str = Field(..., description=" (User ID Örn: emp_4521)")
    prompt: str = Field(..., description="The raw text to be sent to the LLM")

# define the structure of the returning response
class PromptResponse(BaseModel):
    llm_response: str
    status: str

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "Aegis-DLP Backend"}

@app.post("/chat", response_model=PromptResponse)
async def process_prompt(payload: PromptRequest, db: Session = Depends(get_db)):
    try:
        # 1. Aşama: Gelen metni analiz et ve maskele
        analiz = dlp_agent.sanitize_text(payload.prompt)
        
        # 2. Aşama: Veritabanına (Audit Log) kaydet
        yeni_log = AuditLog(
            user_id=payload.user_id,
            original_prompt=payload.prompt,
            sanitized_prompt=analiz["sanitized_text"],
            is_secure=analiz["is_secure"],
            detected_entities=",".join(analiz["detected_entities"])
        )
        db.add(yeni_log)
        db.commit()

        # 3. Aşama: Maskelenmiş metni sahte LLM'e yolla
        llm_cevabi = await mock_llm.generate_response(analiz["sanitized_text"])

        # 4. Aşama: LLM'den gelen cevabı de-anonymize et (eski haline çevir)
        final_cevap = dlp_agent.deanonymize_text(llm_cevabi, analiz["entity_mapping"])

        return PromptResponse(
            llm_response=final_cevap,
            status="Success: Processed, Logged and Re-identified"
        )
        
    except Exception as e:
        # Hatanın ne olduğunu VS Code terminaline KIPKIRMIZI basacak kod:
        print("\n" + "="*50)
        print("SİSTEM ÇÖKTÜ! İŞTE DETAYI:")
        traceback.print_exc()
        print("="*50 + "\n")
        
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main.py:app", host="127.0.0.1", port=8000, reload=True)


@app.get("/logs")
async def get_audit_logs(db: Session = Depends(get_db)):
    """
    Dashboard'da göstermek üzere en son 20 güvenlik logunu getirir.
    """
    # Veritabanından logları en yeniden eskiye doğru sıralayarak çek
    logs = db.query(AuditLog).order_by(AuditLog.timestamp.desc()).limit(20).all()
    
    # iOS tarafının rahat okuyabilmesi için veriyi temiz bir JSON listesine çeviriyoruz
    log_list = []
    for log in logs:
        log_list.append({
            "id": log.id,
            "timestamp": log.timestamp.strftime("%H:%M"), # Saati formatlıyoruz
            "user_id": log.user_id,
            "is_secure": log.is_secure,
            "detected_entities": log.detected_entities,
            "original_prompt": log.original_prompt,
            "sanitized_prompt": log.sanitized_prompt
        })
        
    return log_list    