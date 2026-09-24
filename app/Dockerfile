# Wieloetapowy build — w Bloku 2 pokazujemy, że warstwa z zależnościami
# cache'uje się osobno od warstwy z kodem.
FROM python:3.12-slim AS deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=deps /install /usr/local
COPY main.py flags.py flags.json ./

# Nie root — Checkov i Trivy pytają o to jako pierwsze.
RUN useradd -u 10001 -m app && chown -R app /app
USER app

ARG APP_VERSION=v1
ENV APP_VERSION=${APP_VERSION}
EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s CMD python -c "import urllib.request;urllib.request.urlopen('http://localhost:8000/healthz')"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
