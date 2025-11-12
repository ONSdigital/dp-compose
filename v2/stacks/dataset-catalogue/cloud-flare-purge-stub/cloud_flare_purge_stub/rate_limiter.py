import time

from flask import current_app


class RateLimiter:
    def __init__(self):
        self.calls = []
        self.limiting = False

    def check_if_limited(self):
        if not self.limiting:
            current_time = time.time()
            self.calls = [call for call in self.calls if current_time - call < current_app.config["RATE_LIMIT_PERIOD"]]
            if len(self.calls) >= current_app.config["RATE_LIMIT_REQUESTS"]:
                return True
            self.calls.append(current_time)
            return False
        return True

