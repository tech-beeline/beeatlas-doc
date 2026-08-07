# Global ARG-s (available from all stages)
ARG BUILD_IMAGE=ubuntu:24.04
ARG APP_IMAGE=nginxinc/nginx-unprivileged:alpine

FROM ${BUILD_IMAGE} AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

ARG PIP_INDEX_URL=''
ENV PIP_INDEX_URL=$PIP_INDEX_URL
ARG PIP_TRUSTED_HOST=''
ENV PIP_TRUSTED_HOST=$PIP_TRUSTED_HOST

RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

RUN pip install --no-cache-dir mkdocs mkdocs-material && \
    rm -rf /root/.cache/pip

WORKDIR /build

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY docs/ ./docs/
COPY mkdocs.yml ./

RUN mkdocs build

FROM ${APP_IMAGE} AS app

COPY --from=builder /build/site /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]