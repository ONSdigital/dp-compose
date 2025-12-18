from dis_cloudflare_stub.app_setup import create_app

app = create_app()

if __name__ == "__main__":
    app.run(port=app.config["PORT"], host=app.config["HOST"])
