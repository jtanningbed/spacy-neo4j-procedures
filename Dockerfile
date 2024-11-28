FROM neo4j:latest

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install required Python packages
RUN pip3 install neo4j-driver spacy
RUN python3 -m spacy download en_core_web_sm

# Copy the procedure file
COPY spacy_procedure.py /var/lib/neo4j/

# Set environment variables
ENV NEO4J_apoc_export_file_enabled=true
ENV NEO4J_apoc_import_file_enabled=true
ENV NEO4J_dbms_security_procedures_unrestricted=custom.*

# Enable Python procedures
ENV NEO4J_dbms_security_procedures_whitelist=custom.nlp.*

# Start Neo4j and register procedures
CMD ["sh", "-c", "python3 /var/lib/neo4j/spacy_procedure.py & neo4j start"]