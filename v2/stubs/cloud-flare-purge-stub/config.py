import os


class Config:
    PORT = os.getenv("PORT", "22500")
    HOST = "0.0.0.0"
    CLOUD_FLARE_AUTH_TOKEN = os.getenv("CLOUD_FLARE_AUTH_TOKEN", "test-token")
    RATE_LIMIT_REQUESTS = int(os.getenv("RATE_LIMIT_REQUESTS", 50))
    RATE_LIMIT_PERIOD = int(os.getenv("RATE_LIMIT_PERIOD", 60))