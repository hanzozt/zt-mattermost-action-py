FROM python:3.11-bullseye AS builder
ADD . /app
WORKDIR /app

RUN pip install --target=/app requests openziti==0.8.1

# https://github.com/GoogleContainerTools/distroless
FROM gcr.io/distroless/python3-debian11
COPY --from=builder /app /app
WORKDIR /app
ENV PYTHONPATH=/app
CMD ["/app/zhook.py"]
