# First stage for building dependencies
FROM ghcr.io/astral-sh/uv:python3.11-bookworm as builder

# Create app directory
WORKDIR /app

# Copy dependency files first
COPY pyproject.toml uv.lock ./

# Install dependencies with caching
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync

# Copy and install your spacy procedure code
COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system -e .

# Second stage with Neo4j
FROM neo4j:latest

# Copy Python and dependencies from builder stage
COPY --from=builder /usr/local /usr/local

# Set environment variables for Neo4j
ENV NEO4J_apoc_export_file_enabled=true \
    NEO4J_apoc_import_file_enabled=true \
    NEO4J_dbms_security_procedures_unrestricted=apoc.*,spacy.* \
    NEO4J_dbms_security_procedures_whitelist=apoc.*,spacy.* \
    NEO4J_PLUGINS='["apoc"]' \
    UV_SYSTEM_PYTHON=1

# Copy startup script
RUN echo '#!/bin/bash\n\
    # Start your Python service\n\
    python3 -m spacy_neo4j_procedures &\n\
    \n\
    # Start Neo4j\n\
    neo4j start\n\
    \n\
    # Register procedures\n\
    until cypher-shell -u neo4j -p neo4j "CALL apoc.custom.declareProcedure(\n\
    '\''spacy.nlp.extract_entities(text :: STRING) :: (text :: STRING, label :: STRING, start :: INTEGER, end :: INTEGER)'\'',\n\
    '\''WITH $text AS text\n\
    CALL apoc.load.jsonParams(\"http://localhost:5000/process\", {text: text}, null, null)\n\
    YIELD value\n\
    UNWIND value.entities AS entity\n\
    RETURN \n\
    entity.text AS text,\n\
    entity.label AS label,\n\
    entity.start AS start,\n\
    entity.end AS end'\'',\n\
    '\''READ'\'',\n\
    '\''Extract entities from text using spaCy NLP as a fallback provider'\''\n\
    );" 2>/dev/null; do\n\
    echo "Waiting for Neo4j to be ready..."\n\
    sleep 5\n\
    done\n\
    \n\
    # Keep container running\n\
    tail -f /dev/null' > /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]