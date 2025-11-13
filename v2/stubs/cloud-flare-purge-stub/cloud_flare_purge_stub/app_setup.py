import os

from flask import Flask

from cloud_flare_purge_stub.rate_limiter import RateLimiter

class CloudFlareStub(Flask):
    rate_limiter: RateLimiter

def create_app():
    app = CloudFlareStub("cloud_flare_purge_stub")
    app_config = f'config.{os.environ.get("APP_CONFIG", "Config")}'
    app.config.from_object(app_config)

    app.rate_limiter = RateLimiter()

    from cloud_flare_purge_stub.routes.routes import routes_bp
    app.register_blueprint(routes_bp)

    return app
