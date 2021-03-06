--
-- Copyright 2017 United States Government as represented by the
-- Administrator of the National Aeronautics and Space Administration.
-- All Rights Reserved.
-- 
-- This file is available under the terms of the NASA Open Source Agreement
-- (NOSA). You should have received a copy of this agreement with the
-- Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
-- 
-- No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
-- WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
-- INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
-- WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
-- INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
-- FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
-- TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
-- CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
-- OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
-- OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
-- FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
-- REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
-- AND DISTRIBUTES IT "AS IS."
--
-- Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
-- AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
-- SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
-- THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
-- EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
-- PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
-- SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
-- STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
-- PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
-- REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
-- TERMINATION OF THIS AGREEMENT.
--
CREATE TABLE JPOX_TABLES
(
    CLASS_NAME VARCHAR2(128) NOT NULL UNIQUE,
    "TABLE_NAME" VARCHAR2(128) NOT NULL,
    "TYPE" VARCHAR2(4) NOT NULL,
    OWNER VARCHAR2(2) NOT NULL,
    VERSION VARCHAR2(20) NOT NULL
);

CREATE TABLE ACTIVE_DR_PIPELINE
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    PIPELINE_ID NUMBER NULL
);

ALTER TABLE ACTIVE_DR_PIPELINE ADD CONSTRAINT ACTIVE_DR_PIPELINE_PK PRIMARY KEY (ID);

CREATE TABLE DATASET_TYPE
(
    SHORT_NAME VARCHAR2(100) NOT NULL,
    CATEGORY VARCHAR2(100) NULL,
    DISPLAY_NAME VARCHAR2(100) NULL
);

ALTER TABLE DATASET_TYPE ADD CONSTRAINT DATASET_TYPE_PK PRIMARY KEY (SHORT_NAME);

CREATE TABLE KEY_VALUE_PAIR
(
    "KEY" VARCHAR2(100) NOT NULL,
    "VALUE" VARCHAR2(1000) NULL
);

ALTER TABLE KEY_VALUE_PAIR ADD CONSTRAINT KEY_VALUE_PAIR_PK PRIMARY KEY ("KEY");

CREATE TABLE MODULEPARAMETERSET_PARAMETERS
(
    ID_OID NUMBER NOT NULL,
    STRING_KEY VARCHAR2(255) NOT NULL,
    STRING_VAL VARCHAR2(255) NULL
);

ALTER TABLE MODULEPARAMETERSET_PARAMETERS ADD CONSTRAINT MODULEPARAMETERSET_PARAMJ3_PK PRIMARY KEY (ID_OID,STRING_KEY);

CREATE TABLE PIPELINE
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL,
    DESCRIPTION VARCHAR2(1000) NULL,
    "NAME" VARCHAR2(100) NULL,
    ROOT_NODE_ID NUMBER NULL,
    "TYPE" VARCHAR2(100) NOT NULL
);

ALTER TABLE PIPELINE ADD CONSTRAINT PIPELINE_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_DATASET
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    DATASET_TYPE_ID VARCHAR2(100) NULL,
    END_TIMESTAMP TIMESTAMP NULL,
    PI_ID NUMBER NULL,
    START_TIMESTAMP TIMESTAMP NULL
);

ALTER TABLE PIPELINE_DATASET ADD CONSTRAINT PIPELINE_DATASET_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_INPUT_PARAM_MAP
(
    PIPELINE_ID NUMBER NOT NULL,
    PARAM_NAME_ID NUMBER NOT NULL
);

ALTER TABLE PIPELINE_INPUT_PARAM_MAP ADD CONSTRAINT PIPELINE_INPUT_PARAM_MAP_PK PRIMARY KEY (PIPELINE_ID,PARAM_NAME_ID);

CREATE TABLE PIPELINE_INSTANCE
(
    ID NUMBER NOT NULL,
    CHECK_EXISTING_OUTPUTS NUMBER(1) NOT NULL CHECK (CHECK_EXISTING_OUTPUTS IN ('1','0')),
    CREATED TIMESTAMP NULL,
    PIPELINE_ID NUMBER NULL,
    PRIORITY NUMBER(10) NOT NULL,
    "STATE" NUMBER(10) NOT NULL
);

ALTER TABLE PIPELINE_INSTANCE ADD CONSTRAINT PIPELINE_INSTANCE_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_INSTANCE_NODE
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    PI_ID NUMBER NULL,
    PN_ID NUMBER NULL,
    "STATE" NUMBER(10) NOT NULL,
    UNIT_OF_WORK_ID NUMBER NOT NULL
);

ALTER TABLE PIPELINE_INSTANCE_NODE ADD CONSTRAINT PIPELINE_INSTANCE_NODE_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_INSTANCE_P_MAP
(
    PI_ID NUMBER NOT NULL,
    PARAM_NAME_ID NUMBER NOT NULL,
    PARAM_VALUE_ID NUMBER NULL
);

ALTER TABLE PIPELINE_INSTANCE_P_MAP ADD CONSTRAINT PIPELINE_INSTANCE_P_MAP_PK PRIMARY KEY (PI_ID,PARAM_NAME_ID);

CREATE TABLE PIPELINE_MODULE
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL,
    DESCRIPTION VARCHAR2(1000) NULL,
    IMPLEMENTING_CLASS_NAME VARCHAR2(100) NULL,
    "NAME" VARCHAR2(100) NULL,
    MODULE_PSET_ID NUMBER NULL,
    VERSION VARCHAR2(100) NULL
);

ALTER TABLE PIPELINE_MODULE ADD CONSTRAINT PIPELINE_MODULE_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_MODULE_PSET
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL,
    DESCRIPTION VARCHAR2(1000) NULL,
    "NAME" VARCHAR2(100) NULL,
    VERSION VARCHAR2(100) NULL
);

ALTER TABLE PIPELINE_MODULE_PSET ADD CONSTRAINT PIPELINE_MODULE_PSET_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_NODE
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL,
    MODULE_ID NUMBER NULL
);

ALTER TABLE PIPELINE_NODE ADD CONSTRAINT PIPELINE_NODE_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_NODE_MAP
(
    PN_OWNER_ID NUMBER NOT NULL,
    PN_NEXT_ID NUMBER NULL,
    ORDER_INDEX NUMBER(10) NOT NULL
);

ALTER TABLE PIPELINE_NODE_MAP ADD CONSTRAINT PIPELINE_NODE_MAP_PK PRIMARY KEY (PN_OWNER_ID,ORDER_INDEX);

CREATE TABLE PIPELINE_PARAMETER_NAME
(
    ID NUMBER NOT NULL,
    IS_LIST NUMBER(1) NOT NULL CHECK (IS_LIST IN ('1','0')),
    "NAME" VARCHAR2(100) NULL
);

ALTER TABLE PIPELINE_PARAMETER_NAME ADD CONSTRAINT PIPELINE_PARAMETER_NAME_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_PARAMETER_VALUE
(
    ID NUMBER NOT NULL,
    IS_LIST NUMBER(1) NOT NULL CHECK (IS_LIST IN ('1','0')),
    "VALUE" VARCHAR2(100) NULL
);

ALTER TABLE PIPELINE_PARAMETER_VALUE ADD CONSTRAINT PIPELINE_PARAMETER_VALUE_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_PARAMETER_VL_MAP
(
    PPV_ID NUMBER NOT NULL,
    "VALUE" VARCHAR2(255) NULL,
    ORDER_INDEX NUMBER(10) NOT NULL
);

ALTER TABLE PIPELINE_PARAMETER_VL_MAP ADD CONSTRAINT PIPELINE_PARAMETER_VL_MAP_PK PRIMARY KEY (PPV_ID,ORDER_INDEX);

CREATE TABLE PIPELINE_ROLE
(
    "NAME" VARCHAR2(255) NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL
);

ALTER TABLE PIPELINE_ROLE ADD CONSTRAINT PIPELINE_ROLE_PK PRIMARY KEY ("NAME");

CREATE TABLE PIPELINE_ROLE_PRIV_MAP
(
    PR_ID VARCHAR2(255) NOT NULL,
    PRIVILEGE VARCHAR2(255) NULL,
    ORDER_INDEX NUMBER(10) NOT NULL
);

ALTER TABLE PIPELINE_ROLE_PRIV_MAP ADD CONSTRAINT PIPELINE_ROLE_PRIV_MAP_PK PRIMARY KEY (PR_ID,ORDER_INDEX);

CREATE TABLE PIPELINE_TRIGGER
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL,
    FIRED NUMBER(1) NOT NULL CHECK (FIRED IN ('1','0')),
    INSTANCE_PRIORITY NUMBER(10) NOT NULL,
    PIPELINE_ID NUMBER NULL,
    PI_ID NUMBER NULL,
    "TYPE" VARCHAR2(100) NOT NULL
);

ALTER TABLE PIPELINE_TRIGGER ADD CONSTRAINT PIPELINE_TRIGGER_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_TRIGGER_P_MAP
(
    PT_ID NUMBER NOT NULL,
    PARAM_NAME_ID NUMBER NOT NULL,
    PARAM_VALUE_ID NUMBER NULL
);

ALTER TABLE PIPELINE_TRIGGER_P_MAP ADD CONSTRAINT PIPELINE_TRIGGER_P_MAP_PK PRIMARY KEY (PT_ID,PARAM_NAME_ID);

CREATE TABLE PIPELINE_USER
(
    ID NUMBER NOT NULL,
    CREATED TIMESTAMP NULL,
    CREATED_BY_ID_OID NUMBER NULL,
    DISPLAY_NAME VARCHAR2(20) NULL,
    EMAIL VARCHAR2(50) NULL,
    LOGIN_NAME VARCHAR2(10) NULL,
    PASSWORD VARCHAR2(50) NULL,
    PHONE VARCHAR2(20) NULL
);

ALTER TABLE PIPELINE_USER ADD CONSTRAINT PIPELINE_USER_PK PRIMARY KEY (ID);

CREATE TABLE PIPELINE_USER_PRIV_MAP
(
    PU_ID NUMBER NOT NULL,
    PRIVILEGE VARCHAR2(255) NULL,
    ORDER_INDEX NUMBER(10) NOT NULL
);

ALTER TABLE PIPELINE_USER_PRIV_MAP ADD CONSTRAINT PIPELINE_USER_PRIV_MAP_PK PRIMARY KEY (PU_ID,ORDER_INDEX);

CREATE TABLE PIPELINE_USER_ROLE_MAP
(
    PU_ID NUMBER NOT NULL,
    PR_ID VARCHAR2(255) NULL,
    ORDER_INDEX NUMBER(10) NOT NULL
);

ALTER TABLE PIPELINE_USER_ROLE_MAP ADD CONSTRAINT PIPELINE_USER_ROLE_MAP_PK PRIMARY KEY (PU_ID,ORDER_INDEX);

ALTER TABLE ACTIVE_DR_PIPELINE ADD CONSTRAINT ACTIVE_DR_PIPELINE_FK1 FOREIGN KEY (PIPELINE_ID) REFERENCES PIPELINE (ID) INITIALLY DEFERRED ;

CREATE INDEX ACTIVE_DR_PIPELINE_N49 ON ACTIVE_DR_PIPELINE (PIPELINE_ID);

ALTER TABLE MODULEPARAMETERSET_PARAMETERS ADD CONSTRAINT MODULEPARAMETERSET_PARAMJ3_FK1 FOREIGN KEY (ID_OID) REFERENCES PIPELINE_MODULE_PSET (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE ADD CONSTRAINT PIPELINE_FK2 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE ADD CONSTRAINT PIPELINE_FK1 FOREIGN KEY (ROOT_NODE_ID) REFERENCES PIPELINE_NODE (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_N49 ON PIPELINE (CREATED_BY_ID_OID);

CREATE INDEX PIPELINE_N50 ON PIPELINE (ROOT_NODE_ID);

ALTER TABLE PIPELINE_DATASET ADD CONSTRAINT PIPELINE_DATASET_FK1 FOREIGN KEY (PI_ID) REFERENCES PIPELINE_INSTANCE (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_DATASET_N49 ON PIPELINE_DATASET (PI_ID);

ALTER TABLE PIPELINE_INPUT_PARAM_MAP ADD CONSTRAINT PIPELINE_INPUT_PARAM_MAP_FK1 FOREIGN KEY (PIPELINE_ID) REFERENCES PIPELINE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_INPUT_PARAM_MAP ADD CONSTRAINT PIPELINE_INPUT_PARAM_MAP_FK2 FOREIGN KEY (PARAM_NAME_ID) REFERENCES PIPELINE_PARAMETER_NAME (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_INPUT_PARAM_MAP_N49 ON PIPELINE_INPUT_PARAM_MAP (PARAM_NAME_ID);

ALTER TABLE PIPELINE_INSTANCE ADD CONSTRAINT PIPELINE_INSTANCE_FK1 FOREIGN KEY (PIPELINE_ID) REFERENCES PIPELINE (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_INSTANCE_N49 ON PIPELINE_INSTANCE (PIPELINE_ID);

ALTER TABLE PIPELINE_INSTANCE_NODE ADD CONSTRAINT PIPELINE_INSTANCE_NODE_FK2 FOREIGN KEY (PI_ID) REFERENCES PIPELINE_INSTANCE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_INSTANCE_NODE ADD CONSTRAINT PIPELINE_INSTANCE_NODE_FK1 FOREIGN KEY (PN_ID) REFERENCES PIPELINE_NODE (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_INSTANCE_NODE_N49 ON PIPELINE_INSTANCE_NODE (PI_ID);

CREATE INDEX PIPELINE_INSTANCE_NODE_N50 ON PIPELINE_INSTANCE_NODE (PN_ID);

ALTER TABLE PIPELINE_INSTANCE_P_MAP ADD CONSTRAINT PIPELINE_INSTANCE_P_MAP_FK2 FOREIGN KEY (PARAM_VALUE_ID) REFERENCES PIPELINE_PARAMETER_VALUE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_INSTANCE_P_MAP ADD CONSTRAINT PIPELINE_INSTANCE_P_MAP_FK1 FOREIGN KEY (PI_ID) REFERENCES PIPELINE_INSTANCE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_INSTANCE_P_MAP ADD CONSTRAINT PIPELINE_INSTANCE_P_MAP_FK3 FOREIGN KEY (PARAM_NAME_ID) REFERENCES PIPELINE_PARAMETER_NAME (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_INSTANCE_P_MAP_N49 ON PIPELINE_INSTANCE_P_MAP (PARAM_VALUE_ID);

CREATE INDEX PIPELINE_INSTANCE_P_MAP_N50 ON PIPELINE_INSTANCE_P_MAP (PARAM_NAME_ID);

ALTER TABLE PIPELINE_MODULE ADD CONSTRAINT PIPELINE_MODULE_FK2 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_MODULE ADD CONSTRAINT PIPELINE_MODULE_FK1 FOREIGN KEY (MODULE_PSET_ID) REFERENCES PIPELINE_MODULE_PSET (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_MODULE_N49 ON PIPELINE_MODULE (CREATED_BY_ID_OID);

CREATE INDEX PIPELINE_MODULE_N50 ON PIPELINE_MODULE (MODULE_PSET_ID);

ALTER TABLE PIPELINE_MODULE_PSET ADD CONSTRAINT PIPELINE_MODULE_PSET_FK1 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_MODULE_PSET_N49 ON PIPELINE_MODULE_PSET (CREATED_BY_ID_OID);

ALTER TABLE PIPELINE_NODE ADD CONSTRAINT PIPELINE_NODE_FK1 FOREIGN KEY (MODULE_ID) REFERENCES PIPELINE_MODULE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_NODE ADD CONSTRAINT PIPELINE_NODE_FK2 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_NODE_N50 ON PIPELINE_NODE (MODULE_ID);

CREATE INDEX PIPELINE_NODE_N49 ON PIPELINE_NODE (CREATED_BY_ID_OID);

ALTER TABLE PIPELINE_NODE_MAP ADD CONSTRAINT PIPELINE_NODE_MAP_FK1 FOREIGN KEY (PN_OWNER_ID) REFERENCES PIPELINE_NODE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_NODE_MAP ADD CONSTRAINT PIPELINE_NODE_MAP_FK2 FOREIGN KEY (PN_NEXT_ID) REFERENCES PIPELINE_NODE (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_NODE_MAP_N49 ON PIPELINE_NODE_MAP (PN_NEXT_ID);

ALTER TABLE PIPELINE_PARAMETER_VL_MAP ADD CONSTRAINT PIPELINE_PARAMETER_VL_MAP_FK1 FOREIGN KEY (PPV_ID) REFERENCES PIPELINE_PARAMETER_VALUE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_ROLE ADD CONSTRAINT PIPELINE_ROLE_FK1 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_ROLE_N49 ON PIPELINE_ROLE (CREATED_BY_ID_OID);

ALTER TABLE PIPELINE_ROLE_PRIV_MAP ADD CONSTRAINT PIPELINE_ROLE_PRIV_MAP_FK1 FOREIGN KEY (PR_ID) REFERENCES PIPELINE_ROLE ("NAME") INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_TRIGGER ADD CONSTRAINT PIPELINE_TRIGGER_FK2 FOREIGN KEY (PI_ID) REFERENCES PIPELINE_INSTANCE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_TRIGGER ADD CONSTRAINT PIPELINE_TRIGGER_FK1 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_TRIGGER ADD CONSTRAINT PIPELINE_TRIGGER_FK3 FOREIGN KEY (PIPELINE_ID) REFERENCES PIPELINE (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_TRIGGER_N51 ON PIPELINE_TRIGGER (CREATED_BY_ID_OID);

CREATE INDEX PIPELINE_TRIGGER_N49 ON PIPELINE_TRIGGER (PI_ID);

CREATE INDEX PIPELINE_TRIGGER_N50 ON PIPELINE_TRIGGER (PIPELINE_ID);

ALTER TABLE PIPELINE_TRIGGER_P_MAP ADD CONSTRAINT PIPELINE_TRIGGER_P_MAP_FK1 FOREIGN KEY (PT_ID) REFERENCES PIPELINE_TRIGGER (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_TRIGGER_P_MAP ADD CONSTRAINT PIPELINE_TRIGGER_P_MAP_FK2 FOREIGN KEY (PARAM_VALUE_ID) REFERENCES PIPELINE_PARAMETER_VALUE (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_TRIGGER_P_MAP ADD CONSTRAINT PIPELINE_TRIGGER_P_MAP_FK3 FOREIGN KEY (PARAM_NAME_ID) REFERENCES PIPELINE_PARAMETER_NAME (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_TRIGGER_P_MAP_N49 ON PIPELINE_TRIGGER_P_MAP (PARAM_VALUE_ID);

CREATE INDEX PIPELINE_TRIGGER_P_MAP_N50 ON PIPELINE_TRIGGER_P_MAP (PARAM_NAME_ID);

ALTER TABLE PIPELINE_USER ADD CONSTRAINT PIPELINE_USER_FK1 FOREIGN KEY (CREATED_BY_ID_OID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_USER_N49 ON PIPELINE_USER (CREATED_BY_ID_OID);

ALTER TABLE PIPELINE_USER_PRIV_MAP ADD CONSTRAINT PIPELINE_USER_PRIV_MAP_FK1 FOREIGN KEY (PU_ID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_USER_ROLE_MAP ADD CONSTRAINT PIPELINE_USER_ROLE_MAP_FK1 FOREIGN KEY (PU_ID) REFERENCES PIPELINE_USER (ID) INITIALLY DEFERRED ;

ALTER TABLE PIPELINE_USER_ROLE_MAP ADD CONSTRAINT PIPELINE_USER_ROLE_MAP_FK2 FOREIGN KEY (PR_ID) REFERENCES PIPELINE_ROLE ("NAME") INITIALLY DEFERRED ;

CREATE INDEX PIPELINE_USER_ROLE_MAP_N49 ON PIPELINE_USER_ROLE_MAP (PR_ID);

