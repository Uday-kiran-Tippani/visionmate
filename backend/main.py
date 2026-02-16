from fastapi import FastAPI
from pydantic import BaseModel
from intent_engine.engine import IntentEngine

app = FastAPI()
intent_engine = IntentEngine()

class CommandRequest(BaseModel):
    command: str
    user_id: str

@app.get("/")
def read_root():
    return {"status": "VisionMate Backend Running"}

@app.post("/process_command")
def process_command(request: CommandRequest):
    response = intent_engine.process(request.command)
    return {"response": response}
