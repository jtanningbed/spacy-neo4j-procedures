# Neo4j spaCy Procedures

A custom Neo4j procedure that integrates spaCy's NLP capabilities with Neo4j queries, designed to work with the Model Context Protocol (MCP) server for enhanced graph database interactions.

## Overview

This plugin provides natural language processing capabilities as Neo4j procedures, allowing you to:
- Extract entities from text during queries
- Create relationships based on NLP analysis
- Enable LLMs to interact with Neo4j through natural language
- Support fallback NLP functionality when other providers aren't available

## Installation

### Prerequisites
- Neo4j instance with APOC procedures enabled
- Python 3.8+
- spaCy with required language models

### Docker Installation
```bash
docker build -t neo4j-spacy .
docker run -p 7474:7474 -p 7687:7687 -p 5000:5000 neo4j-spacy
```

## Usage

### Basic Entity Extraction
```cypher
CALL custom.spacy.nlp.extract_entities("John works at Google in Mountain View") 
YIELD text, label, start, end
RETURN text, label;
```

Example output:
```
╒════════════╤═══════╕
│ text       │ label │
╞════════════╪═══════╡
│ John       │ PERSON│
├────────────┼───────┤
│ Google     │ ORG   │
├────────────┼───────┤
│ Mountain   │ GPE   │
│ View       │       │
╘════════════╧═══════╛
```

### Integration with MCP Server
This procedure is designed to work with the MCP (Model Context Protocol) Neo4j server, enabling:
- Natural language queries against Neo4j
- Automated relationship creation based on NLP analysis
- Enhanced context understanding for graph operations

Example MCP workflow:
```python
# MCP server using the procedure for entity extraction
await tx.run("""
    MATCH (doc:Document) 
    WHERE doc.text IS NOT NULL
    CALL custom.spacy.nlp.extract_entities(doc.text)
    YIELD text, label
    CREATE (e:Entity {name: text, type: label})
    CREATE (doc)-[:HAS_ENTITY]->(e)
""")
```

## Deployment Options

### Local Neo4j Instance
1. Install the procedure
2. Register it using `apoc.custom.declareProcedure`
3. Configure security settings to allow the procedure

### Managed Neo4j Instances
- Ensure APOC and custom procedures are enabled
- Configure network access for the spaCy service
- Set appropriate security policies

## Configuration

The procedure can be registered with:
```cypher
CALL apoc.custom.declareProcedure(
    'spacy.nlp.extract_entities(text :: STRING) :: (text :: STRING, label :: STRING, start :: INTEGER, end :: INTEGER)',
    'WITH $text AS text
     CALL apoc.load.jsonParams("http://localhost:5000/process", {text: text}, null, null)
     YIELD value
     UNWIND value.entities AS entity
     RETURN 
         entity.text AS text,
         entity.label AS label,
         entity.start AS start,
         entity.end AS end',
    'READ',
    'Extract entities from text using spaCy NLP as a fallback provider'
);
```

## Security Considerations
- The procedure runs with READ privileges only
- Network access is required between Neo4j and the spaCy service
- Consider authentication for the spaCy service in production environments

## Contributing
Contributions are welcome! Please feel free to submit pull requests or open issues for:
- Additional NLP capabilities
- Performance improvements
- Documentation enhancements
- Bug fixes

## License
This project is licensed under the MIT License - see the LICENSE file for details.