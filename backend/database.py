from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime

# PostgreSQL'e geçmek için burayı "postgresql://user:password@localhost/dbname" yapacağız
SQLALCHEMY_DATABASE_URL = "sqlite:///./aegis_audit.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# CISO'ların göreceği Log Tablosu
class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    user_id = Column(String, index=True)
    original_prompt = Column(String)
    sanitized_prompt = Column(String)
    is_secure = Column(Boolean)
    detected_entities = Column(String)

# Tabloları veritabanında oluştur
Base.metadata.create_all(bind=engine)