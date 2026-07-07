-- 2.1 LOCATION
INSERT INTO LOCATION (LocationID, Area, City, State, PinCode) VALUES
(11, 'Navrangpura',     'Ahmedabad', 'Gujarat',     '380009'),
(12, 'Baner',           'Pune',      'Maharashtra', '411045'),
(13, 'Koramangala',     'Bangalore', 'Karnataka',   '560034'),
(14, 'Connaught Place', 'Delhi',     'Delhi',       '110001'),
(15, 'Anna Nagar',      'Chennai',   'Tamil Nadu',  '600040');

-- 2.2 HOSPITAL
INSERT INTO HOSPITAL
    (HospitalID, HospitalName, ContactPersonName, ContactNumber,
     Email, RegistrationDate, LocationID)
VALUES
(1001, 'Apollo Hospitals Ahmedabad',  'Dr. Ramesh Shah',    '07926301610', 'admin@apolloahm.in',     '2020-01-15', 11),
(1002, 'Ruby Hall Clinic',            'Ms. Priya Kulkarni', '02066455100', 'contact@rubyhall.in',    '2018-06-10', 12),
(1003, 'Manipal Hospitals Bangalore', 'Dr. Sunita Rao',     '08025023000', 'info@manipalbng.in',     '2019-03-22', 13),
(1004, 'Sir Ganga Ram Hospital',      'Mr. Anil Mehta',     '01125750000', 'admin@sgrh.in',          '2017-09-05', 14),
(1005, 'Apollo Hospitals Chennai',    'Dr. Kavitha Nair',   '04428296000', 'admin@apollochennai.in', '2021-02-28', 15);

-- 2.3 DEPARTMENT
INSERT INTO DEPARTMENT (DepartmentID, DepartmentName) VALUES
(101, 'Cardiology'),
(102, 'ICU'),
(103, 'General Surgery'),
(104, 'Neurology'),
(105, 'Orthopaedics'),
(106, 'Oncology'),
(107, 'Emergency Medicine'),
(108, 'Paediatrics'),
(109, 'Radiology'),
(110, 'Gynaecology');

-- 2.4 HOSPITAL_DEPARTMENT
INSERT INTO HOSPITAL_DEPARTMENT (HospitalID, DepartmentID, FloorNumber, ContactExtension) VALUES
(1001, 101, 3, '301'),
(1001, 102, 2, '201'),
(1001, 107, 1, '101'),
(1002, 103, 4, '401'),
(1002, 104, 5, '501'),
(1002, 102, 3, '302'),
(1003, 105, 3, '301'),
(1003, 106, 6, '601'),
(1003, 101, 4, '402'),
(1004, 107, 1, '102'),
(1004, 108, 2, '202'),
(1004, 102, 2, '203'),
(1005, 109, 1, '102'),
(1005, 110, 4, '403'),
(1005, 106, 5, '502');

-- 2.5 SPECIALIZATION
INSERT INTO SPECIALIZATION (SpecializationID, SpecializationName, Description) VALUES
(201, 'Cardiology',         'Diagnosis and treatment of heart disorders'),
(202, 'Neurology',          'Disorders of the nervous system'),
(203, 'Orthopaedics',       'Musculoskeletal system disorders'),
(204, 'Oncology',           'Cancer diagnosis and treatment'),
(205, 'General Surgery',    'Wide range of surgical procedures'),
(206, 'Paediatrics',        'Medical care of infants and children'),
(207, 'Radiology',          'Imaging for diagnosis and therapy'),
(208, 'Gynaecology',        'Female reproductive health'),
(209, 'Emergency Medicine', 'Acute illness and injury care'),
(210, 'Anaesthesiology',    'Perioperative care and pain management');

-- 2.6 INDEPENDENT_CONSULTANT
INSERT INTO INDEPENDENT_CONSULTANT
    (ConsultantID, FirstName, LastName, LicenseNo, Email,
     SpecializationID, YearsOfExperience, RegistrationDate, Status)
VALUES
(1201, 'Arjun',  'Mehta',  'MH-CARD-10021', 'arjun.mehta@consult.in',  201, 15, '2022-01-10', 'Active'),
(1202, 'Sneha',  'Iyer',   'KA-NEUR-20034', 'sneha.iyer@consult.in',   202, 10, '2022-03-05', 'Active'),
(1203, 'Rohit',  'Sharma', 'DL-ORTH-30045', 'rohit.sharma@consult.in', 203,  8, '2022-07-20', 'Active'),
(1204, 'Priya',  'Nair',   'TN-ONCO-40056', 'priya.nair@consult.in',   204, 12, '2023-01-15', 'Active'),
(1205, 'Vikram', 'Patel',  'GJ-SURG-50067', 'vikram.patel@consult.in', 205, 20, '2021-06-01', 'Active'),
(1206, 'Ananya', 'Desai',  'MH-PAED-60078', 'ananya.desai@consult.in', 206,  6, '2023-04-10', 'Active'),
(1207, 'Suresh', 'Kumar',  'TN-RADI-70089', 'suresh.kumar@consult.in', 207, 11, '2022-09-30', 'Active'),
(1208, 'Meera',  'Pillai', 'KA-GYNE-80090', 'meera.pillai@consult.in', 208,  9, '2023-02-14', 'Active'),
(1209, 'Kiran',  'Joshi',  'DL-EMER-90101', 'kiran.joshi@consult.in',  209, 14, '2021-11-20', 'Inactive'),
(1210, 'Naveen', 'Rao',    'GJ-ANES-10112', 'naveen.rao@consult.in',   210, 18, '2020-08-08', 'Active');

-- 2.7 CONSULTANT_PHONE
INSERT INTO CONSULTANT_PHONE (ConsultantID, ContactNo) VALUES
(1201, '9876543210'),
(1201, '9988776655'),
(1202, '8765432109'),
(1203, '7654321098'),
(1203, '9123456780'),
(1204, '6543210987'),
(1205, '9812345670'),
(1205, '9901234567'),
(1205, '9090909090'),
(1206, '8901234567'),
(1207, '7890123456'),
(1208, '6789012345'),
(1209, '5678901234'),
(1210, '9112233445'),
(1210, '9223344556');

-- 2.8 CALL_TYPE
INSERT INTO CALL_TYPE (CallTypeID, TypeName, UrgencyLevel, DefaultDuration) VALUES
(5001, 'Emergency On-Call',  'Emergency', 180),
(5002, 'Scheduled Surgery',  'Medium',    240),
(5003, 'ICU Coverage',       'High',      480),
(5004, 'Outpatient Consult', 'Low',        60),
(5005, 'Second Opinion',     'Low',        45),
(5006, 'Post-Op Review',     'Medium',     90);

-- 2.9 AVAILABILITY_SLOT
INSERT INTO AVAILABILITY_SLOT (ConsultantID, AvailableDate, StartTime, EndTime, SlotStatus) VALUES
(1201, '2026-04-10', '08:00', '12:00', 'Available'),
(1201, '2026-04-11', '14:00', '18:00', 'Available'),
(1202, '2026-04-10', '09:00', '13:00', 'Booked'),
(1202, '2026-04-12', '10:00', '14:00', 'Available'),
(1203, '2026-04-10', '08:00', '16:00', 'Available'),
(1203, '2026-04-13', '07:00', '15:00', 'Available'),
(1205, '2026-04-10', '06:00', '14:00', 'Booked'),
(1205, '2026-04-13', '08:00', '12:00', 'Available'),
(1207, '2026-04-11', '09:00', '17:00', 'Available'),
(1208, '2026-04-12', '08:00', '16:00', 'Available'),
(1210, '2026-04-10', '07:00', '15:00', 'Available'),
(1210, '2026-04-14', '08:00', '14:00', 'Available');

-- 2.10 CALL_REQUEST
INSERT INTO CALL_REQUEST
    (CallID, HospitalID, DepartmentID, CallTypeID, RequiredSpecializationID,
     CallDate, StartTime, ExpectedDuration, FeeOffered, Status, CreatedTimestamp)
VALUES
(3001, 1001, 101, 5001, 201, '2026-04-10', '10:00', 180,  8000.00, 'Open',      '2026-04-08 09:00:00'),
(3002, 1001, 102, 5003, 209, '2026-04-10', '08:00', 480, 15000.00, 'Open',      '2026-04-08 10:00:00'),
(3003, 1002, 103, 5002, 205, '2026-04-11', '09:00', 240, 12000.00, 'Assigned',  '2026-04-07 11:00:00'),
(3004, 1002, 104, 5004, 202, '2026-04-11', '11:00',  60,  3000.00, 'Completed', '2026-04-06 14:00:00'),
(3005, 1003, 105, 5002, 203, '2026-04-12', '08:00', 240, 10000.00, 'Assigned',  '2026-04-09 08:00:00'),
(3006, 1003, 106, 5004, 204, '2026-04-12', '14:00',  60,  4000.00, 'Completed', '2026-04-05 15:00:00'),
(3007, 1004, 107, 5001, 209, '2026-04-10', '06:00', 180,  9000.00, 'Completed', '2026-04-07 07:00:00'),
(3008, 1004, 108, 5004, 206, '2026-04-13', '10:00',  60,  3500.00, 'Open',      '2026-04-09 09:00:00'),
(3009, 1005, 109, 5004, 207, '2026-04-11', '10:00',  60,  3000.00, 'Completed', '2026-04-08 08:00:00'),
(3010, 1005, 110, 5002, 208, '2026-04-12', '09:00', 240, 11000.00, 'Assigned',  '2026-04-09 10:00:00'),
(3011, 1001, 101, 5005, 201, '2026-04-13', '11:00',  45,  2500.00, 'Cancelled', '2026-04-09 11:00:00'),
(3012, 1002, 103, 5006, 205, '2026-04-13', '14:00',  90,  5000.00, 'Open',      '2026-04-09 12:00:00'),
(3013, 1003, 105, 5001, 203, '2026-04-14', '07:00', 180,  9500.00, 'Open',      '2026-04-09 13:00:00'),
(3014, 1004, 107, 5003, 210, '2026-04-14', '08:00', 480, 14000.00, 'Open',      '2026-04-09 14:00:00'),
(3015, 1005, 109, 5004, 207, '2026-04-14', '13:00',  60,  3200.00, 'Open',      '2026-04-09 15:00:00');

-- 2.11 ASSIGNMENT
INSERT INTO ASSIGNMENT
    (CallID, ConsultantID, AssignedTimestamp,
     AcceptanceTimestamp, CompletionTimestamp, AssignmentStatus)
VALUES
(3003, 1205, '2026-04-07 12:00:00', '2026-04-07 12:30:00', NULL,                  'Accepted'),
(3004, 1202, '2026-04-06 15:00:00', '2026-04-06 15:20:00', '2026-04-11 12:00:00', 'Completed'),
(3005, 1203, '2026-04-09 09:00:00', '2026-04-09 09:15:00', NULL,                  'Accepted'),
(3006, 1204, '2026-04-05 16:00:00', '2026-04-05 16:10:00', '2026-04-12 15:00:00', 'Completed'),
(3007, 1209, '2026-04-07 08:00:00', '2026-04-07 08:05:00', '2026-04-10 09:00:00', 'Completed'),
(3009, 1207, '2026-04-08 09:00:00', '2026-04-08 09:30:00', '2026-04-11 11:00:00', 'Completed'),
(3010, 1208, '2026-04-09 11:00:00', '2026-04-09 11:45:00', NULL,                  'Accepted');

-- 2.12 PAYMENT
INSERT INTO PAYMENT
    (PaymentID, CallID, ConsultantID, AmountToBePaid, AmountPaid,
     PaymentDate, PaymentMode, PaymentStatus)
VALUES
(40001, 3004, 1202,  3000.00, 3000.00, '2026-04-12', 'BankTransfer', 'Completed'),
(40002, 3006, 1204,  4000.00, 2000.00, '2026-04-13', 'UPI',          'Partial'),
(40003, 3007, 1209,  9000.00,    0.00,  NULL,          NULL,          'Pending'),
(40004, 3009, 1207,  3000.00, 3000.00, '2026-04-12', 'Online',       'Completed'),
(40005, 3010, 1208, 11000.00, 5000.00, '2026-04-13', 'Cheque',       'Partial');

