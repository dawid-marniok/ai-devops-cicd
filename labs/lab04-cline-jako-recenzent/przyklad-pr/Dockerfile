FROM python:alpine

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

ENV AWS_DEFAULT_REGION=eu-central-1
ENV APP_SECRET_KEY=tymczasowy-klucz-do-podmiany-przed-produkcja

EXPOSE 8000
CMD uvicorn main:app --host 0.0.0.0 --port 8000
