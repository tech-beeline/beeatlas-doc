# Global ARG-s (available from all stages)
ARG BUILD_IMAGE=ubuntu:24.04
ARG APP_IMAGE=nginxinc/nginx-unprivileged:alpine

FROM ${BUILD_IMAGE} as builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 pip && \
    rm -rf /var/lib/apt/lists/*

ARG PIP_INDEX_URL=''
ENV PIP_INDEX_URL=$PIP_INDEX_URL
ARG PIP_TRUSTED_HOST=''
ENV PIP_TRUSTED_HOST=$PIP_TRUSTED_HOST

RUN python3 -m pip install --no-cache-dir mkdocs mkdocs-material && \
    rm -rf /root/.cache/pip && \
    rm -rf /usr/local/lib/python3.10/dist-packages/__pycache__

WORKDIR /build

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY docs/ ./docs/
COPY mkdocs.yml ./

RUN mkdocs build

# Second stage
FROM ${APP_IMAGE} as app

COPY --from=builder /build/site /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]