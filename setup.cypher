CALL apoc.custom.declareProcedure(
    'spacy.nlp.extract_entities(text :: STRING) :: (text :: STRING, label :: STRING, start :: INTEGER, end :: INTEGER)',
    'WITH $text AS text
     CALL apoc.load.jsonParams($spacy_endpoint, {text: text}, null, null) 
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