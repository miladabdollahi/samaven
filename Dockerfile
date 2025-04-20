# ===============================
# 🏗️ Stage 1: Builder environment
# ===============================
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    libldap2-dev \
    libsasl2-dev \
    libffi-dev \
    libssl-dev \
    && apt-get clean

WORKDIR /opt/build

COPY requirements.txt /opt/build/
RUN pip install --upgrade pip
RUN pip install --prefix=/install -r requirements.txt

# ===============================
# 🐍 Stage 2: Runtime environment
# ===============================
FROM python:3.12-slim

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get install -y \
    libpq5 \
    libxml2 \
    libxslt1.1 \
    libjpeg62-turbo \
    libldap-2.5-0 \
    libsasl2-2 \
    libffi8 \
    libssl3 \
    git \
    nodejs \
    npm \
    wget \
    curl \
    && apt-get clean

RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb \
    && dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb || apt -f install -y \
    && rm wkhtmltox_0.12.6-1.bionic_amd64.deb

RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

COPY --from=builder /install /usr/local

WORKDIR /opt/odoo

COPY --chown=odoo:odoo ./ /opt/odoo

