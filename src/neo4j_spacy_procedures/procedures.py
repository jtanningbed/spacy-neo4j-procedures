"""Neo4j procedures using spaCy for NLP tasks."""
from typing import Dict, Optional
import spacy
from neo4j import GraphDatabase
import logging


def setup_logging(name: Optional[str] = None) -> logging.Logger:
    """Set up a logger with consistent formatting."""
    logger = logging.getLogger(name or __name__)

    if not logger.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)

    return logger

logger = setup_logging(__name__)

class SpacyNLPProcedure:
    """Provides Neo4j procedures powered by spaCy NLP."""

    def __init__(self, uri: str, user: str, password: str):
        """Initialize the procedure with Neo4j connection details."""
        self.driver = GraphDatabase.driver(uri, auth=(user, password))
        try:
            self.nlp = spacy.load("en_core_web_sm")
            logger.info("Loaded spaCy English model successfully")
        except OSError:
            logger.warning("Downloading spaCy English model...")
            spacy.cli.download("en_core_web_sm")
            self.nlp = spacy.load("en_core_web_sm")

    def close(self):
        """Close the Neo4j driver connection."""
        self.driver.close()

    def register_procedures(self):
        """Register all spaCy procedures with Neo4j."""
        with self.driver.session() as session:
            # Register entity extraction
            session.run(
                """
                CALL apoc.custom.declareProcedure('custom.nlp.spacy.entities(text :: STRING)',
                'RETURNS MAP
                LANGUAGE PYTHON
                CALL custom.nlp.spacy.extract_entities($text) as entities')
            """
            )
            logger.info("Registered custom.nlp.spacy.entities procedure")

    def extract_entities(self, text: str) -> Dict:
        """
        Extract named entities from text using spaCy.

        Args:
            text: Input text to analyze

        Returns:
            Dict containing entities and metadata in APOC NLP-compatible format
        """
        doc = self.nlp(text)

        entities = [
            {
                "text": ent.text,
                "type": ent.label_,
                "score": 1.0,  # spaCy doesn't provide confidence scores
                "beginOffset": ent.start_char,
                "endOffset": ent.end_char
            }
            for ent in doc.ents
        ]

        return {
            "entities": entities,
            "language": doc.lang_,
            "text": text,
            "provider": "spacy"
        }
