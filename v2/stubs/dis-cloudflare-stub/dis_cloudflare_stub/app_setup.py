import os

from flask import Flask

from dis_cloudflare_stub.rate_limiter import RateLimiter

class CloudflareStub(Flask):
    rate_limiter: RateLimiter

def create_app():
    app = CloudflareStub("cloudflare_stub")
    app_config = f'config.{os.environ.get("APP_CONFIG", "Config")}'
    app.config.from_object(app_config)

    app.rate_limiter = RateLimiter()

    from dis_cloudflare_stub.routes.routes import routes_bp
    app.register_blueprint(routes_bp)

    return app
