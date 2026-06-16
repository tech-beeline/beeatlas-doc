# Инструкция по интеграции через fdm-gateway (HMAC-аутентификация)
## Обзор
**fdm-gateway** — единая внешняя точка входа в экосистему FDM. Все запросы к микросервисам проходят через шлюз, который:

- Проверяет аутентификацию (JWT или HMAC)
- Обогащает запрос заголовками пользователя перед передачей в бэкенды
- Маршрутизирует запрос на нужный сервис по префиксу пути

Для интеграции «сервис-сервис» используется **HMAC-аутентификация** через заголовок `X-Authorization`.

## HMAC-аутентификация
### Получение ключей
Каждый продукт имеет **API Key** и **API Secret**. Их можно посмотреть на странице продукта в UI. При аутентификации через `X-Authorization` шлюз:

1. По API Key запрашивает секрет у fdm-products
2. Вычисляет HMAC-SHA256 от канонической строки запроса
3. Сравнивает с подписью из заголовка

### Формат заголовка
```
X-Authorization: {apiKey}:{base64Signature}
```
### Каноническая строка для подписи
Строка формируется из компонентов запроса, разделённых переводом строки `\n`:

```
{HTTP_METHOD}\n{PATH}\n{MD5_BODY}\n{CONTENT_TYPE}\n{NONCE}
```

| Компонент | Описание |
|-----------|----------|
| `HTTP_METHOD` | Метод запроса в верхнем регистре: `GET`, `POST`, `PUT`, `PATCH`, `DELETE` |
| `PATH` | Путь запроса без query-параметров |
| `MD5_BODY` | MD5-хеш тела запроса в hex. Для запросов без тела — MD5 пустой строки |
| `CONTENT_TYPE` | Значение заголовка `Content-Type`. Для запросов без тела — пустая строка |
| `NONCE` | Значение заголовка `Nonce` — уникальная строка для каждого запроса |

### Алгоритм подписи

1. Собрать каноническую строку
2. Вычислить **HMAC-SHA256** от канонической строки с использованием **API Secret** как ключа
3. Закодировать результат в **Base64**
4. Подставить в заголовок: `X-Authorization: {apiKey}:{base64Signature}`

### Обязательные заголовки

| Заголовок | Обязательность | Описание |
|-----------|:-:|---------|
| `X-Authorization` | ✅ | `{apiKey}:{base64Signature}` |
| `Nonce` | ✅ | Уникальное значение для каждого запроса (UUID или timestamp) |
| `Content-Type` | ❌ | Для запросов с телом: `application/json` |

> **Важно:** нельзя одновременно передавать `Authorization` и `X-Authorization` — шлюз вернёт **400**.

## Вспомогательная функция для подписи (bash)

Для удобства тестирования приведём bash-функцию, которая формирует заголовок `X-Authorization`:

```bash
#!/bin/bash
# hmac_sign.sh — вспомогательная функция для HMAC-подписи запросов
GATEWAY_URL="https://fdm-gateway.example.com"
API_KEY="your-api-key"
API_SECRET="your-api-secret"
sign_request() {
  local method="$1"
  local path="$2"
  local body="$3"
  local content_type="$4"
  local nonce="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
  
  # MD5 тела (пустая строка для GET-запросов без тела)
  if [ -z "$body" ]; then
    local md5_body=$(echo -n "" | md5 | awk '{print $1}')
  else
    local md5_body=$(echo -n "$body" | md5 | awk '{print $1}')
  fi
  
  # Каноническая строка
  local canonical="${method}\n${path}\n${md5_body}\n${content_type}\n${nonce}"
  
  # HMAC-SHA256 подпись в Base64
  local signature=$(printf "%b" "$canonical" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
  
  echo "X-Authorization: ${API_KEY}:${signature}"
  echo "Nonce: ${nonce}"
  echo "Content-Type: ${content_type}"
}
# Пример использования:
# sign_request "GET" "/api/v1/product/my-product/info" "" ""
```

## Маршрутизация шлюза
Шлюз перенаправляет запросы по префиксу пути на соответствующий бэкенд-сервис:

| Префикс пути | Целевой сервис |
|-------------|----------------|
| `/product/...` | fdm-products |
| `/capability/...` | capability-backend |
| `/techradar/...` | techradar-backend |
| `/cx/...` | cx-backend |
| `/structurizr-backend/...` | structurizr-backend |
| `/notification/...` | fdm-notifications-management |
| `/package/...` | fdm-pack-loader |
| `/camunda/...` | fdm-bpm |
| `/doc/...` | document-service |
| `/user/...` | fdm-auth |
| `/arch-graph/...` | architect-graph-service |

> В примерах ниже используется базовый URL шлюза `https://fdm-gateway.example.com`. Подставьте ваш реальный URL.
---

## Сценарий 1. Создание продукта

### Метод
`PUT /product/api/v1/product/{code}` — fdm-products
Создаёт или обновляет продукт по коду (alias).

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="PUT"
PATH="/product/api/v1/product/MY-PRODUCT"
BODY='{
  "name": "Мой продукт",
  "description": "Описание продукта",
  "alias": "MY-PRODUCT",
  "critical": "HIGH"
}'
CONTENT_TYPE="application/json"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
# MD5 тела
MD5_BODY=$(echo -n "$BODY" | md5 | awk '{print $1}')
# Каноническая строка
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${CONTENT_TYPE}
${NONCE}"
# Подпись
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X PUT "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d "$BODY"
```

### Ответ
**200** — без тела (успешное создание/обновление).
---

## Сценарий 2. Получение информации о продукте

### Метод
`GET /product/api/v1/product/{code}/info` — fdm-products
Возвращает информацию о продукте v1, включая список технологий (`techProducts`).

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="GET"
PATH="/product/api/v1/product/MY-PRODUCT/info"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
# GET без тела — MD5 пустой строки
MD5_BODY=$(echo -n "" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X GET "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}"
```
### Ответ
**200** — `ProductInfoDTO`:

```json
{
  "alias": "MY-PRODUCT",
  "description": "Описание продукта",
  "id": "123",
  "name": "Мой продукт",
  "techProducts": [
    {
      "id": 0,
      "techId": 42,
      "source": "Sparx",
      "createdDate": "2025-01-01T00:00:00"
    }
  ],
  "critical": "HIGH",
  "ownerName": "Иванов И.И.",
  "ownerEmail": "ivanov@example.com"
}
```

> Для расширенной информации о технологиях (с названиями, кольцами, секторами) используйте `GET /product/api/v2/product/{code}/info`.
---

## Сценарий 3. Запись контейнеров, интерфейсов и методов для продукта

### Метод
`PUT /product/api/v1/product/{code}/relations` — fdm-products
Создаёт/обновляет связи продукта: контейнеры, интерфейсы, методы. 

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="PUT"
PATH="/product/api/v1/product/MY-PRODUCT/relations"
BODY='[
  {
    "name": "string",
    "code": "string",
    "version": "string",
    "interfaces": [
      {
        "name": "string",
        "code": "string",
        "version": "string",
        "capabilityCode": "string",
        "protocol": "string",
        "methods": [
          {
            "name": "string",
            "description": "string",
            "returnType": "string",
            "parameters": [
              {
                "name": "string",
                "type": "string"
              }
            ],
            "sla": {
              "rps": 0,
              "latency": 0,
              "error_rate": 0
            },
            "capabilityCode": "string",
            "type": "string"
          }
        ],
        "sla": {
          "rps": 0,
          "latency": 0,
          "error_rate": 0
        },
        "specification": "string"
      }
    ]
  }
]'
CONTENT_TYPE="application/json"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "$BODY" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${CONTENT_TYPE}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X PUT "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d "$BODY"
```

### Ответ
- **200** — успех
---

## Сценарий 4. Создание бизнес-возможности (BC)

### Метод
`PUT /capability/api/v1/business-capability` — capability-backend
Создаёт или обновляет бизнес-возможность.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="PUT"
PATH="/capability/api/v1/business-capability"
BODY='{
  "code": "BC-MY-CAPABILITY",
  "name": "Моя бизнес-возможность",
  "description": "Описание бизнес-возможности",
  "isDomain": false,
  "parentCode": "BC-PARENT-CODE"
}'
CONTENT_TYPE="application/json"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "$BODY" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${CONTENT_TYPE}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X PUT "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d "$BODY"
```

### Ответ
- **200** — без тела (успех).
---

## Сценарий 5. Создание технической возможности (TC)
### Метод
`PUT /capability/api/v1/tech-capabilities` — capability-backend
Создаёт или обновляет техническую возможность.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="PUT"
PATH="/capability/api/v1/tech-capabilities"
BODY='{
  "code": "TC-MY-CAPABILITY",
  "name": "Моя техническая возможность",
  "description": "Описание технической возможности",
  "targetSystemCode": "MY-PRODUCT"
}'
CONTENT_TYPE="application/json"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "$BODY" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${CONTENT_TYPE}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X PUT "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d "$BODY"
```

### Ответ
- **200** — без тела (успех).
---

## Сценарий 6. Получение бизнес-возможностей
### Метод
`GET /capability/api/v1/business-capability` — capability-backend
Возвращает список BC с пагинацией.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="GET"
PATH="/capability/api/v1/business-capability?limit=50&offset=0"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X GET "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}"
```

### Ответ
**200** — массив `BusinessCapabilityShortDTO`:
```json
[
  {
    "id": 0,
    "code": "BC-CODE",
    "name": "Название BC",
    "description": "Описание",
    "isDomain": false,
    "hasChildren": true,
    "parent": { "id": 0, "code": "string", "name": "string" }
  }
]
```
---

## Сценарий 7. Получение технических возможностей

### Метод
`GET /capability/api/v1/tech-capabilities` — capability-backend
Возвращает список TC.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="GET"
PATH="/capability/api/v1/tech-capabilities?limit=50&offset=0"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X GET "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}"
```

### Ответ
**200** — массив `TechCapabilityDTO`:
```json
[
  {
    "id": 0,
    "code": "TC-CODE",
    "name": "Название TC",
    "description": "Описание",
    "parents": [
      { "id": 0, "code": "string", "name": "string" }
    ]
  }
]
```
---

## Сценарий 8. Создание новой технологии

### Метод
`POST /techradar/api/v1/tech` — techradar-backend
Пакетное создание технологий. При совпадении `label` с существующей технологией возвращает **409**.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="POST"
PATH="/techradar/api/v1/tech"
BODY='[
  {
    "label": "My Technology",
    "ring_id": 1,
    "sector_id": 2,
    "description": "Описание технологии",
    "link": "https://docs.example.com"
  }
]'
CONTENT_TYPE="application/json"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "$BODY" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${CONTENT_TYPE}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X POST "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d "$BODY"
```

### Ответ
**201** — массив с ID созданных технологий:
```json
[
  { "id": 42 }
]
```
---

## Сценарий 9. Получение существующих технологий
### Метод
`GET /techradar/api/v1/tech` — techradar-backend
Возвращает список технологий с версиями и историей.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="GET"
PATH="/techradar/api/v1/tech?actualTech=true"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X GET "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}"
```

### Ответ
**200** — массив `TechAdvancedDTO`:
```json
[
  {
    "id": 42,
    "label": "My Technology",
    "review": true,
    "description": "Описание",
    "ring": { "id": 1, "name": "Adopt", "order": 0 },
    "sector": { "id": 2, "name": "Languages", "order": 0 },
    "isCritical": false,
    "category": [],
    "versions": [],
    "history": []
  }
]
```
---

## Сценарий 10. Загрузка связи технологии и продукта
### Метод
`POST /product/api/v1/product-tech-relation/{techId}` — fdm-products
Добавляет связь продукта с технологией по `techId`.

### curl
```bash
API_KEY="your-api-key"
API_SECRET="your-api-secret"
GATEWAY="https://fdm-gateway.example.com"
METHOD="POST"
PATH="/product/api/v1/product-tech-relation/42"
BODY='{
  "cmdb_code": "MY-PRODUCT"
}'
CONTENT_TYPE="application/json"
NONCE="$(uuidgen 2>/dev/null || echo "$(date +%s%N)")"
MD5_BODY=$(echo -n "$BODY" | md5 | awk '{print $1}')
CANONICAL="${METHOD}
${PATH}
${MD5_BODY}
${CONTENT_TYPE}
${NONCE}"
SIGNATURE=$(printf "%s" "$CANONICAL" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)
curl -X POST "${GATEWAY}${PATH}" \
  -H "X-Authorization: ${API_KEY}:${SIGNATURE}" \
  -H "Nonce: ${NONCE}" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d "$BODY"
```
### Ответ
**200** — без тела (успех).
---

## Сводная таблица сценариев
| # | Сценарий | Сервис | Метод | Путь |
|:-:|----------|--------|-------|------|
| 1 | Создание продукта | fdm-products | PUT | `/product/api/v1/product/{code}` |
| 2 | Получение информации о продукте (v1) | fdm-products | GET | `/product/api/v1/product/{code}/info` |
| 3 | Получение информации о продукте (v2, с технологиями) | fdm-products | GET | `/product/api/v2/product/{code}/info` |
| 4 | Получение списка всех продуктов | fdm-products | GET | `/product/api/v1/product/info` |
| 5 | Запись контейнеров/интерфейсов/методов | fdm-products | PUT | `/product/api/v1/product/{code}/relations` |
| 6 | Создание BC | capability-backend | PUT | `/capability/api/v1/business-capability` |
| 7 | Создание TC | capability-backend | PUT | `/capability/api/v1/tech-capabilities` |
| 8 | Получение BC | capability-backend | GET | `/capability/api/v1/business-capability` |
| 9 | Получение TC | capability-backend | GET | `/capability/api/v1/tech-capabilities` |
| 10 | Создание технологии | techradar-backend | POST | `/techradar/api/v1/tech` |
| 11 | Получение технологий | techradar-backend | GET | `/techradar/api/v1/tech` |
| 12 | Связь технологии и продукта | fdm-products | POST | `/product/api/v1/product-tech-relation/{techId}` |

---

## Коды ошибок

| Код | Описание |
|------|----------|
| **400** | Ошибка валидации / неверные параметры |
| **401** | Неверная подпись HMAC |
| **403** | Недостаточно прав |
| **404** | Сущность не найдена |
| **409** | Конфликт |
| **503** | Ошибка S3 / внешнего сервиса |

---

## Примечания

1. **Порядок операций** при заведении нового продукта с технологиями:
   - Создать продукт (сценарий 1)
   - Создать/найти технологии (сценарии 8, 9)
   - Создать TC при необходимости (сценарий 5)
   - Записать контейнеры и интерфейсы (сценарий 3)
   - Привязать технологии к продукту (сценарий 10)
2. **HMAC-подпись для GET-запросов без тела**: MD5 вычисляется от пустой строки, `Content-Type` в канонической строке — пустое значение.
3. **Nonce** должен быть уникальным для каждого запроса. Рекомендуется использовать UUID или timestamp с наносекундами.
4. **Шлюз удаляет заголовок `Authorization`** перед передачей в бэкенды — downstream-сервисы получают только доверенные заголовки `user-id`, `user-roles`, `user-permission`, `user-products-ids`, добавленные шлюзом.
5. **Прочие доступные для интеграции методы** описаны в openAPI спецификации - **[Ссылка на спецификацию](openapi-gateway-specification.yaml)**
