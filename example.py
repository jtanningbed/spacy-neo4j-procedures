#!/usr/bin/env python
# test.py
from neo4j_spacy_procedures import SpacyNLPProcedure

# # Initialize without actually connecting to Neo4j
# nlp = SpacyNLPProcedure("bolt://localhost:7687", "neo4j", "test")

# # Test entity extraction
# text = "Apple is looking at buying U.K. startup for $1 billion"
# result = nlp.extract_entities(text)
# print("Extracted entities:")
# for entity in result["entities"]:
#     print(f"- {entity['text']} ({entity['type']})")



# Connect to your running container
proc = SpacyNLPProcedure("bolt://localhost:7687", "neo4j", "password")

# Register the procedure
proc.register_procedures()

# Test with a simple text
text = "Apple is looking at buying U.K. startup for $1 billion"
with proc.driver.session() as session:
    result = session.run("CALL custom.nlp.spacy.entities($text)", text=text)
    print(result.single())
