"""Tests for Neo4j spaCy procedures."""
import pytest

from neo4j_spacy_procedures import SpacyNLPProcedure


@pytest.fixture
def nlp_procedure():
    """Create a SpacyNLPProcedure instance for testing."""
    proc = SpacyNLPProcedure(
        uri="bolt://localhost:7687",
        user="neo4j",
        password="test"
    )
    yield proc
    proc.close()

def test_extract_entities(nlp_procedure):
    """Test entity extraction from text."""
    text = "Apple is looking at buying U.K. startup for $1 billion"
    result = nlp_procedure.extract_entities(text)

    assert "entities" in result
    assert len(result["entities"]) > 0
    assert "provider" in result
    assert result["provider"] == "spacy"

    # Check entity format
    entity = result["entities"][0]
    assert all(k in entity for k in [
        "text",
        "type",
        "score",
        "beginOffset",
        "endOffset"
        ]
        )
