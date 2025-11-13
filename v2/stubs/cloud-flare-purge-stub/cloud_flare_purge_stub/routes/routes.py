import http
import random

from flask import Response, request, Blueprint, current_app
from flask.json import dumps


routes_bp = Blueprint("routes_bp", __name__)

body_types = {"tags": list, "hosts": list, "prefixes": list, "purge_everything": bool, "files": list}


@routes_bp.post("/zones/<zone_id>/purge_cache")
def purge(zone_id):
    if current_app.rate_limiter.check_if_limited():
        return Response(dumps(__build_response_body(zone_id, error_message="Rate limit exceeded")),
                        http.HTTPStatus.TOO_MANY_REQUESTS, mimetype="application/json")

    if not zone_id.isalnum() or len(zone_id) != 32:
        return Response(dumps(__build_response_body(zone_id, error_message="Invalid zone_id")),
                        http.HTTPStatus.BAD_REQUEST, mimetype="application/json")

    headers = request.headers
    bearer = headers.get("Authorization", "")
    if not bearer.startswith("Bearer ") or current_app.config['CLOUD_FLARE_AUTH_TOKEN'] not in bearer:
        return Response(dumps(__build_response_body(zone_id, error_message="Unauthorized")),
                        http.HTTPStatus.UNAUTHORIZED, mimetype="application/json")

    request_body = request.get_json()
    if not request_body:
        return Response(dumps(__build_response_body(zone_id, error_message="Missing request body")),
                        http.HTTPStatus.BAD_REQUEST, mimetype="application/json")

    request_body_key = [key for key in request_body]
    if len(request_body_key) > 1:
        return Response(dumps(__build_response_body(zone_id, error_message="Invalid request body")),
                        http.HTTPStatus.BAD_REQUEST, mimetype="application/json")
    if not any(key in request_body for key in body_types.keys()):
        return Response(dumps(__build_response_body(zone_id, error_message="Invalid request body")),
                        http.HTTPStatus.BAD_REQUEST, mimetype="application/json")

    if len(request_body[request_body_key[0]]) > 1000:
        return Response(
            dumps(__build_response_body(zone_id, error_message="Request body exceeds maximum allowed items")),
            http.HTTPStatus.BAD_REQUEST, mimetype="application/json")

    return Response(dumps(__build_response_body(zone_id)), http.HTTPStatus.OK, mimetype="application/json")


@routes_bp.put("/rate_limit")
def set_limiting():
    current_app.rate_limiter.limiting = not current_app.rate_limiter.limiting
    return Response(dumps({"rate limiting": current_app.rate_limiter.limiting}), http.HTTPStatus.OK,
                    mimetype="application/json")


@routes_bp.get("/health")
def health_check():
    return Response(dumps({"status": "healthy"}), http.HTTPStatus.OK, mimetype="application/json")


def __build_response_body(zone_id, error_message=None):
    if error_message:
        return {
            "errors": [
                {
                    "code": random.randint(1000, 9999),
                    "message": error_message,
                    "minLength": 1
                }
            ],
            "messages": [],
            "result": {
                "id": zone_id
            },
            "success": False
        }
    return {
        "errors": [],
        "messages": [],
        "result": {
            "id": zone_id
        },
        "success": True
    }
