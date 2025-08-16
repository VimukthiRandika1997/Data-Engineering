import os
from fastapi import FastAPI

app = FastAPI(title="Terraform GCP API", version="1.0.0")
# Get configuration from environment variables
PROJECT_ID = os.environ.get('PROJECT_ID', 'your-project-id')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'dev')

@app.get("/")
def read_root():
    return {
        "message": "Hello from Cloud Run!",
        "project_id": PROJECT_ID,
        "environment": ENVIRONMENT
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {
        "item_id": item_id, 
        "q": q,
        "environment": ENVIRONMENT
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)