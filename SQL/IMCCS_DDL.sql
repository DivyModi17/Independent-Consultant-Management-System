-- ================================================================
-- INDEPENDENT MEDICAL CONSULTANT COORDINATION SYSTEM (IMCCS)
-- IT214 - Database Management System
-- MASTER SETUP SCRIPT (Option B: 12-table schema)
-- Safe to re-run: drops and recreates schema from scratch.
-- ================================================================

-- Drop and recreate schema (safe re-run)
DROP SCHEMA IF EXISTS consultant_mgmt CASCADE;
CREATE SCHEMA consultant_mgmt;
SET search_path TO consultant_mgmt;

-- ================================================================
-- SECTION 1: DDL - TABLE DEFINITIONS
-- ================================================================

-- 1. LOCATION
CREATE TABLE LOCATION (
    LocationID  SERIAL PRIMARY KEY,
    Area        VARCHAR(150),
    City        VARCHAR(100) NOT NULL,
    State       VARCHAR(100) NOT NULL,
    PinCode     VARCHAR(20)
);

-- 2. HOSPITAL
CREATE TABLE HOSPITAL (
    HospitalID          SERIAL PRIMARY KEY,
    HospitalName        VARCHAR(200) NOT NULL,
    ContactPersonName   VARCHAR(150),
    ContactNumber       VARCHAR(20),
    Email               VARCHAR(150) UNIQUE,
    RegistrationDate    DATE,
    LocationID          INT NOT NULL,
    CONSTRAINT fk_hospital_location
        FOREIGN KEY (LocationID) REFERENCES LOCATION(LocationID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 3. DEPARTMENT (reference table of department types)
CREATE TABLE DEPARTMENT (
    DepartmentID        SERIAL PRIMARY KEY,
    DepartmentName      VARCHAR(150) NOT NULL UNIQUE
);

-- 4. HOSPITAL_DEPARTMENT (M:N junction)
CREATE TABLE HOSPITAL_DEPARTMENT (
    HospitalID          INT NOT NULL,
    DepartmentID        INT NOT NULL,
    FloorNumber         INT,
    ContactExtension    VARCHAR(20),
    PRIMARY KEY (HospitalID, DepartmentID),
    CONSTRAINT fk_hd_hospital
        FOREIGN KEY (HospitalID) REFERENCES HOSPITAL(HospitalID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_hd_department
        FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENT(DepartmentID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5. SPECIALIZATION
CREATE TABLE SPECIALIZATION (
    SpecializationID    SERIAL PRIMARY KEY,
    SpecializationName  VARCHAR(150) NOT NULL UNIQUE,
    Description         TEXT
);

-- 6. INDEPENDENT_CONSULTANT
CREATE TABLE INDEPENDENT_CONSULTANT (
    ConsultantID        SERIAL PRIMARY KEY,
    FirstName           VARCHAR(100) NOT NULL,
    LastName            VARCHAR(100) NOT NULL,
    LicenseNo           VARCHAR(80)  NOT NULL UNIQUE,
    Email               VARCHAR(150) NOT NULL UNIQUE,
    SpecializationID    INT,
    YearsOfExperience   INT,
    RegistrationDate    DATE,
    Status              VARCHAR(40)  NOT NULL DEFAULT 'Active'
                            CHECK (Status IN ('Active', 'Inactive', 'Suspended')),
    CONSTRAINT fk_consultant_specialization
        FOREIGN KEY (SpecializationID) REFERENCES SPECIALIZATION(SpecializationID)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- 7. CONSULTANT_PHONE
CREATE TABLE CONSULTANT_PHONE (
    ConsultantID    INT         NOT NULL,
    ContactNo       VARCHAR(20) NOT NULL,
    PRIMARY KEY (ConsultantID, ContactNo),
    CONSTRAINT fk_cphone_consultant
        FOREIGN KEY (ConsultantID) REFERENCES INDEPENDENT_CONSULTANT(ConsultantID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 8. CALL_TYPE
CREATE TABLE CALL_TYPE (
    CallTypeID      SERIAL PRIMARY KEY,
    TypeName        VARCHAR(100) NOT NULL,
    UrgencyLevel    VARCHAR(40)
                        CHECK (UrgencyLevel IN ('Low', 'Medium', 'High', 'Emergency')),
    DefaultDuration INT
);

-- 9. AVAILABILITY_SLOT (weak entity)
CREATE TABLE AVAILABILITY_SLOT (
    ConsultantID    INT     NOT NULL,
    AvailableDate   DATE    NOT NULL,
    StartTime       TIME    NOT NULL,
    EndTime         TIME    NOT NULL,
    SlotStatus      VARCHAR(40) NOT NULL DEFAULT 'Available'
                        CHECK (SlotStatus IN ('Available', 'Booked', 'Cancelled')),
    PRIMARY KEY (ConsultantID, AvailableDate, StartTime),
    CONSTRAINT fk_slot_consultant
        FOREIGN KEY (ConsultantID) REFERENCES INDEPENDENT_CONSULTANT(ConsultantID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_slot_time CHECK (EndTime > StartTime)
);

-- 10. CALL_REQUEST
CREATE TABLE CALL_REQUEST (
    CallID                      SERIAL PRIMARY KEY,
    HospitalID                  INT             NOT NULL,
    DepartmentID                INT,
    CallTypeID                  INT             NOT NULL,
    RequiredSpecializationID    INT             NOT NULL,
    CallDate                    DATE            NOT NULL,
    StartTime                   TIME,
    ExpectedDuration            INT,
    FeeOffered                  NUMERIC(10, 2),
    Status                      VARCHAR(40)     NOT NULL DEFAULT 'Open'
                                    CHECK (Status IN ('Open', 'Assigned', 'Completed', 'Cancelled')),
    CreatedTimestamp            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cr_hospital
        FOREIGN KEY (HospitalID) REFERENCES HOSPITAL(HospitalID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cr_hosp_dept
        FOREIGN KEY (HospitalID, DepartmentID)
        REFERENCES HOSPITAL_DEPARTMENT(HospitalID, DepartmentID)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_cr_calltype
        FOREIGN KEY (CallTypeID) REFERENCES CALL_TYPE(CallTypeID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cr_specialization
        FOREIGN KEY (RequiredSpecializationID) REFERENCES SPECIALIZATION(SpecializationID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 11. ASSIGNMENT
CREATE TABLE ASSIGNMENT (
    CallID                  INT         NOT NULL,
    ConsultantID            INT         NOT NULL,
    AssignedTimestamp       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    AcceptanceTimestamp     TIMESTAMP,
    CompletionTimestamp     TIMESTAMP,
    AssignmentStatus        VARCHAR(40) NOT NULL DEFAULT 'Pending'
                                CHECK (AssignmentStatus IN
                                    ('Pending', 'Accepted', 'Rejected', 'Completed', 'Cancelled')),
    PRIMARY KEY (CallID, ConsultantID),
    CONSTRAINT fk_assign_call
        FOREIGN KEY (CallID) REFERENCES CALL_REQUEST(CallID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_assign_consultant
        FOREIGN KEY (ConsultantID) REFERENCES INDEPENDENT_CONSULTANT(ConsultantID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 12. PAYMENT
CREATE TABLE PAYMENT (
    PaymentID       SERIAL PRIMARY KEY,
    CallID          INT             NOT NULL,
    ConsultantID    INT             NOT NULL,
    AmountToBePaid  NUMERIC(10, 2)  NOT NULL,
    AmountPaid      NUMERIC(10, 2)  DEFAULT 0,
    PaymentDate     DATE,
    PaymentMode     VARCHAR(60)
                        CHECK (PaymentMode IN ('Cash', 'BankTransfer', 'UPI', 'Cheque', 'Online')),
    PaymentStatus   VARCHAR(40)     NOT NULL DEFAULT 'Pending'
                        CHECK (PaymentStatus IN ('Pending', 'Partial', 'Completed', 'Failed')),
    CONSTRAINT fk_pay_assignment
        FOREIGN KEY (CallID, ConsultantID) REFERENCES ASSIGNMENT(CallID, ConsultantID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
