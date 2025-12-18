FROM python:3.13-slim

ENV POETRY_VERSION=2.2.1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock* ./
RUN poetry install --no-root --only main
EXPOSE 30200

COPY . .

RUN poetry build -f wheel && pip install --no-cache-dir dist/*.whl && rm -rf dist

CMD ["python", "-m", "run"]