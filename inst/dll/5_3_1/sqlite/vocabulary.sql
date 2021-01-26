CREATE TABLE `concept` (
  `concept_id`       INTEGER PRIMARY KEY NOT NULL ,
  `concept_name`     TEXT NOT NULL ,
  `domain_id`        TEXT  NOT NULL ,
  `vocabulary_id`     TEXT  NOT NULL ,
  `concept_class_id`  TEXT  NOT NULL ,
  `standard_concept`  TEXT  NULL ,
  `concept_code`     TEXT  NOT NULL ,
  `valid_start_date`  TEXT       NOT NULL ,
  `valid_end_date`    TEXT       NOT NULL ,
  `invalid_reason`    TEXT  NULL,
  FOREIGN KEY (domain_id) REFERENCES domain (domain_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (concept_class_id) REFERENCES domain (concept_class_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (vocabulary_id) REFERENCES domain (vocabulary_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `vocabulary` (
  `vocabulary_id`       TEXT PRIMARY KEY NOT NULL,
  `vocabulary_name`      TEXT NOT NULL,
  `vocabulary_reference` TEXT NOT NULL,
  `vocabulary_version`   TEXT NULL,
  `vocabulary_concept_id` INTEGER     NOT NULL,
  FOREIGN KEY (vocabulary_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `domain` (
  `domain_id`       TEXT PRIMARY KEY NOT NULL,
  `domain_name`      TEXT NOT NULL,
  `domain_concept_id` INTEGER     NOT NULL,
  FOREIGN KEY (domain_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `concept_class` (
  `concept_class_id`       TEXT PRIMARY KEY  NOT NULL,
  `concept_class_name`      TEXT NOT NULL,
  `concept_class_concept_id` INTEGER     NOT NULL,
  FOREIGN KEY (concept_class_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `concept_relationship` (
  `concept_id_1`   INTEGER NOT NULL,
  `concept_id_2`   INTEGER NOT NULL,
  `relationship_id`  TEXT NOT NULL,
  `valid_start_date` TEXT NOT NULL,
  `valid_end_date`  TEXT NOT NULL,
  `invalid_reason`  TEXT NULL,
  PRIMARY KEY (concept_id_1, concept_id_2, relationship_id),
  FOREIGN KEY (concept_id_1) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (concept_id_2) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (relationship_id) REFERENCES relationship (relationship_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `relationship` (
  `relationship_id`       TEXT PRIMARY KEY NOT NULL,
  `relationship_name`     TEXT NOT NULL,
  `is_hierarchical`       TEXT  NOT NULL,
  `defines_ancestry`    TEXT  NOT NULL,
  `reverse_relationship_id` TEXT  NOT NULL,
  `relationship_concept_id` INTEGER     NOT NULL,
  FOREIGN KEY (relationship_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (reverse_relationship_id) REFERENCES relationship (relationship_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `concept_synonym` (
  `concept_id`         INTEGER     NOT NULL,
  `concept_synonym_name` TEXT NOT NULL,
  `language_concept_id`   INTEGER     NOT NULL,
  FOREIGN KEY (concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (language_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `concept_ancestor` (
  `ancestor_concept_id`      INTEGER  NOT NULL,
  `descendant_concept_id`    INTEGER  NOT NULL,
  `min_levels_of_separation` INTEGER  NOT NULL,
  `max_levels_of_separation` INTEGER  NOT NULL,
  PRIMARY KEY (ancestor_concept_id, descendant_concept_id),
  FOREIGN KEY (ancestor_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (descendant_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `source_to_concept_map` (
  `source_code`          TEXT  NOT NULL,
  `source_concept_id`     INTEGER     NOT NULL,
  `source_vocabulary_id`  TEXT  NOT NULL,
  `source_code_description` TEXT NULL,
  `target_concept_id`     INTEGER     NOT NULL,
  `target_vocabulary_id`  TEXT  NOT NULL,
  `valid_start_date`     TEXT       NOT NULL,
  `valid_end_date`       TEXT       NOT NULL,
  `invalid_reason`       TEXT  NULL,
  PRIMARY KEY (source_vocabulary_id, target_concept_id, source_code, valid_end_date),
  FOREIGN KEY (source_vocabulary_id) REFERENCES vocabulary (vocabulary_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (source_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (target_vocabulary_id) REFERENCES vocabulary (vocabulary_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (target_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `drug_strength` (
  `drug_concept_id`          INTEGER    NOT NULL,
  `ingredient_concept_id`     INTEGER    NOT NULL,
  `amount_value`           REAL      NULL,
  `amount_unit_concept_id`    INTEGER    NULL,
  `numerator_value`          REAL      NULL,
  `numerator_unit_concept_id`  INTEGER    NULL,
  `denominator_value`        REAL      NULL,
  `denominator_unit_concept_id` INTEGER    NULL,
  `box_size`              INTEGER    NULL,
  `valid_start_date`        TEXT      NOT NULL,
  `valid_end_date`          TEXT      NOT NULL,
  `invalid_reason`          TEXT  NULL,
  PRIMARY KEY (`drug_concept_id`, `ingredient_concept_id`),
  FOREIGN KEY (drug_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (ingredient_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (amount_unit_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (numerator_unit_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (denominator_unit_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `cohort_definition` (
  `cohort_definition_id`        INTEGER PRIMARY KEY    NOT NULL,
  `cohort_definition_name`       TEXT NOT NULL,
  `cohort_definition_description`  TEXT NULL,
  `definition_type_concept_id`    INTEGER     NOT NULL,
  `cohort_definition_syntax`     TEXT NULL,
  `subject_concept_id`          INTEGER     NOT NULL,
  `cohort_initiation_date`       TEXT       NULL,
  FOREIGN KEY (definition_type_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (subject_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE `attribute_definition` (
  `attribute_definition_id`    INTEGER  PRIMARY KEY   NOT NULL,
  `attribute_name`          TEXT NOT NULL,
  `attribute_description`     TEXT NULL,
  `attribute_type_concept_id`  INTEGER     NOT NULL,
  `attribute_syntax`        TEXT NULL,
  FOREIGN KEY (attribute_type_concept_id) REFERENCES concept (concept_id) DEFERRABLE INITIALLY DEFERRED
);
