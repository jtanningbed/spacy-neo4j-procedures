FROM neo4j:latest

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install required Python packages
RUN pip3 install neo4j-driver spacy
RUN python3 -m spacy download en_core_web_sm

# Create a directory for your project
WORKDIR /app

# Copy your project files
COPY ./src/spacy_neo4j_procedures /app/spacy_neo4j_procedures
COPY ./setup.py /app/

# Install your package
RUN pip3 install -e .

# Set Neo4j environment variables
ENV NEO4J_apoc_export_file_enabled=true
ENV NEO4J_apoc_import_file_enabled=true
ENV NEO4J_dbms_security_procedures_unrestricted=apoc.*,spacy.*
ENV NEO4J_dbms_security_procedures_whitelist=apoc.*,spacy.*
ENV NEO4J_PLUGINS=["apoc"]

# Copy startup script
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]