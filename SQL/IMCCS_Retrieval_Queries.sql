================================================================
INDEPENDENT MEDICAL CONSULTANT COORDINATION SYSTEM (IMCCS)
IT214 - Database Management System

FILE 2: RETRIEVAL QUERIES - QUERY TEXT AND SQL SELECT QUERIES
================================================================

SET search_path TO consultant_mgmt;


================================================================
Q1: Available Consultants for a Specific Date & Specialization
================================================================

QUERY TEXT:
Find all active independent consultants who have an available
slot on a given date (2026-04-10) that matches the required
specialization (Cardiology). Results are ranked by years of
experience in descending order so that the most experienced
consultant appears first. This is the core search a Hospital
Admin performs before posting a formal call request.

Primary User    : Hospital Admin
SQL Concepts    : 3-table JOIN, WHERE with multiple filters,
                  ORDER BY ranking by experience.

SQL SELECT QUERY:

SELECT
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName  AS ConsultantName,
    s.SpecializationName,
    ic.YearsOfExperience,
    avs.AvailableDate,
    avs.StartTime,
    avs.EndTime
FROM AVAILABILITY_SLOT avs
JOIN INDEPENDENT_CONSULTANT ic ON ic.ConsultantID    = avs.ConsultantID
JOIN SPECIALIZATION          s  ON s.SpecializationID = ic.SpecializationID
WHERE avs.AvailableDate    = '2026-04-10'
  AND avs.SlotStatus       = 'Available'
  AND ic.Status            = 'Active'
  AND s.SpecializationName = 'Cardiology'
ORDER BY ic.YearsOfExperience DESC;


================================================================
Q2: Hospital & Department Request Dashboard (ROLLUP)
================================================================

QUERY TEXT:
Produce a unified operational dashboard that shows request
counts and a status breakdown (Open, Assigned, Completed,
Cancelled) at both the department level and the hospital
subtotal level, all in a single query. ROLLUP generates
subtotals per hospital and a grand total row automatically.
COALESCE replaces NULL group labels with readable subtotal
headings.

Primary User    : Hospital Management / Platform Admin
SQL Concepts    : GROUPING SETS / ROLLUP, conditional aggregation
                  (CASE WHEN), LEFT JOIN for nullable DepartmentID,
                  multi-level GROUP BY, COALESCE for subtotal labels.

SQL SELECT QUERY:

SELECT
    COALESCE(h.HospitalName,   '*** GRAND TOTAL ***')    AS HospitalName,
    COALESCE(d.DepartmentName, '-- Hospital Subtotal --') AS DepartmentName,
    COUNT(cr.CallID)                                       AS TotalRequests,
    COUNT(CASE WHEN cr.Status = 'Open'      THEN 1 END)   AS Open,
    COUNT(CASE WHEN cr.Status = 'Assigned'  THEN 1 END)   AS Assigned,
    COUNT(CASE WHEN cr.Status = 'Completed' THEN 1 END)   AS Completed,
    COUNT(CASE WHEN cr.Status = 'Cancelled' THEN 1 END)   AS Cancelled,
    ROUND(AVG(cr.FeeOffered), 2)                           AS AvgFeeOffered
FROM CALL_REQUEST cr
JOIN      HOSPITAL    h ON h.HospitalID   = cr.HospitalID
JOIN      LOCATION    l ON l.LocationID   = h.LocationID
LEFT JOIN DEPARTMENT  d ON d.DepartmentID = cr.DepartmentID
GROUP BY ROLLUP(h.HospitalName, d.DepartmentName)
ORDER BY h.HospitalName NULLS LAST, d.DepartmentName NULLS LAST;


================================================================
Q3: Specialization Demand Analysis (Conditional Aggregation)
================================================================

QUERY TEXT:
Analyse demand across all medical specializations by counting
total call requests, how many were completed, how many are
still open, and how many were cancelled — along with the
average fee offered per specialization. This helps the platform
admin identify under-served specializations where more
consultants need to be recruited.

Primary User    : Platform Admin / Business Analyst
SQL Concepts    : CASE WHEN inside COUNT (conditional aggregation),
                  ROUND, GROUP BY, ORDER BY.

SQL SELECT QUERY:

SELECT
    s.SpecializationName,
    COUNT(cr.CallID)                                      AS TotalRequests,
    COUNT(CASE WHEN cr.Status = 'Completed' THEN 1 END)   AS Completed,
    COUNT(CASE WHEN cr.Status = 'Open'      THEN 1 END)   AS Open,
    COUNT(CASE WHEN cr.Status = 'Cancelled' THEN 1 END)   AS Cancelled,
    ROUND(AVG(cr.FeeOffered), 2)                           AS AvgFeeOffered
FROM CALL_REQUEST cr
JOIN SPECIALIZATION s ON s.SpecializationID = cr.RequiredSpecializationID
GROUP BY s.SpecializationName
ORDER BY TotalRequests DESC;


================================================================
Q4: Consultant Workload Summary - Consultations & Hours
    (LEFT JOIN + COALESCE)
================================================================

QUERY TEXT:
Show every consultant's completed consultation count and the
total hours worked (derived from ExpectedDuration in minutes).
Consultants who have not yet completed any assignment still
appear in the result with zero counts, thanks to LEFT JOINs.
This gives admins a full workload picture across all registered
consultants.

Primary User    : Admin / Consultant
SQL Concepts    : 3-table LEFT JOIN chain, COALESCE to handle NULLs,
                  COUNT/SUM aggregation, arithmetic (minutes / 60).

SQL SELECT QUERY:

SELECT
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName   AS ConsultantName,
    s.SpecializationName,
    ic.Status,
    COUNT(a.CallID)                               AS CompletedConsultations,
    COALESCE(SUM(cr.ExpectedDuration), 0) / 60.0  AS TotalHoursWorked
FROM INDEPENDENT_CONSULTANT ic
JOIN  SPECIALIZATION s  ON s.SpecializationID  = ic.SpecializationID
LEFT JOIN ASSIGNMENT  a  ON a.ConsultantID      = ic.ConsultantID
    AND a.AssignmentStatus = 'Completed'
LEFT JOIN CALL_REQUEST cr ON cr.CallID          = a.CallID
GROUP BY ic.ConsultantID, ic.FirstName, ic.LastName,
         s.SpecializationName, ic.Status
ORDER BY TotalHoursWorked DESC;


================================================================
Q5: Pending Payment Report (Derived Column)
================================================================

QUERY TEXT:
List all assignments where payment is still Pending or only
Partial, showing the outstanding balance (BalanceDue) as a
derived column calculated as AmountToBePaid minus AmountPaid.
Results are sorted by BalanceDue in descending order so the
largest outstanding amounts appear first. This is critical for
the finance team's accounts-receivable follow-up.

Primary User    : Finance / Accounts Team
SQL Concepts    : 4-table JOIN, IN-list filter, derived column
                  (BalanceDue = AmountToBePaid - AmountPaid),
                  ORDER BY on derived column.

SQL SELECT QUERY:

SELECT
    p.PaymentID,
    h.HospitalName,
    ic.FirstName || ' ' || ic.LastName  AS ConsultantName,
    cr.CallDate,
    p.AmountToBePaid,
    p.AmountPaid,
    (p.AmountToBePaid - p.AmountPaid)   AS BalanceDue,
    p.PaymentStatus,
    p.PaymentMode
FROM PAYMENT p
JOIN CALL_REQUEST           cr ON cr.CallID       = p.CallID
JOIN HOSPITAL                h  ON h.HospitalID   = cr.HospitalID
JOIN INDEPENDENT_CONSULTANT ic  ON ic.ConsultantID = p.ConsultantID
WHERE p.PaymentStatus IN ('Pending', 'Partial')
ORDER BY BalanceDue DESC;


================================================================
Q6: Consultants Never Assigned to Any Request
    (NOT EXISTS Anti-Join)
================================================================

QUERY TEXT:
Identify consultants who have never been assigned to any call
request on the platform. These could be newly registered
consultants or Inactive ones whose profiles need review.
NOT EXISTS is used instead of NOT IN to safely handle potential
NULL values in the subquery.

Primary User    : Admin / Recruitment
SQL Concepts    : NOT EXISTS correlated subquery (anti-semi-join),
                  safer than NOT IN when NULLs could exist.

SQL SELECT QUERY:

SELECT
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName  AS ConsultantName,
    s.SpecializationName,
    ic.YearsOfExperience,
    ic.Status,
    ic.RegistrationDate
FROM INDEPENDENT_CONSULTANT ic
JOIN SPECIALIZATION s ON s.SpecializationID = ic.SpecializationID
WHERE NOT EXISTS (
    SELECT 1 FROM ASSIGNMENT a
    WHERE a.ConsultantID = ic.ConsultantID
)
ORDER BY ic.RegistrationDate;


================================================================
Q7: Scheduling Conflict Detection (Self-Join)
================================================================

QUERY TEXT:
Detect cases where the same consultant has been assigned to two
overlapping calls on the same date. The self-join on ASSIGNMENT
uses a1.CallID < a2.CallID to avoid returning duplicate pairs.
Allen's interval overlap logic checks that one call starts
before the other ends and vice versa. This is a critical
data-integrity diagnostic for the scheduling team.

Primary User    : Platform / Scheduler
SQL Concepts    : Self-join on ASSIGNMENT, Allen interval overlap
                  logic, INTERVAL arithmetic with ::text cast.

SQL SELECT QUERY:

SELECT
    a1.ConsultantID,
    ic.FirstName || ' ' || ic.LastName                                    AS ConsultantName,
    cr1.CallID                                                             AS Call1,
    cr1.CallDate,
    cr1.StartTime                                                          AS Start1,
    cr1.StartTime + (cr1.ExpectedDuration::text || ' minutes')::INTERVAL  AS End1,
    cr2.CallID                                                             AS Call2,
    cr2.StartTime                                                          AS Start2,
    cr2.StartTime + (cr2.ExpectedDuration::text || ' minutes')::INTERVAL  AS End2
FROM ASSIGNMENT a1
JOIN ASSIGNMENT a2
    ON  a1.ConsultantID = a2.ConsultantID
    AND a1.CallID < a2.CallID
JOIN CALL_REQUEST           cr1 ON cr1.CallID      = a1.CallID
JOIN CALL_REQUEST           cr2 ON cr2.CallID      = a2.CallID
JOIN INDEPENDENT_CONSULTANT ic  ON ic.ConsultantID = a1.ConsultantID
WHERE cr1.CallDate = cr2.CallDate
  AND a1.AssignmentStatus NOT IN ('Rejected', 'Cancelled')
  AND a2.AssignmentStatus NOT IN ('Rejected', 'Cancelled')
  AND cr1.StartTime < (cr2.StartTime + (cr2.ExpectedDuration::text || ' minutes')::INTERVAL)
  AND cr2.StartTime < (cr1.StartTime + (cr1.ExpectedDuration::text || ' minutes')::INTERVAL);


================================================================
Q8: Hospital Spending vs Actual Payments (LEFT JOIN)
================================================================

QUERY TEXT:
Compare what each hospital offered in fees (FeeOffered) against
what was actually paid out (AmountPaid). A CTE pre-aggregates
payments per call, and a LEFT JOIN ensures hospitals with no
payments still appear. The PaymentGap derived column highlights
the settlement shortfall at the hospital level.

Primary User    : Finance / Admin
SQL Concepts    : WITH clause (CTE) to pre-aggregate payments,
                  LEFT JOIN to preserve hospitals with no payments,
                  SUM aggregation, derived PaymentGap column,
                  COALESCE for NULL handling.

SQL SELECT QUERY:

WITH PaidPerCall AS (
    SELECT  CallID,
            COALESCE(SUM(AmountPaid), 0) AS TotalPaid
    FROM    PAYMENT
    GROUP BY CallID
)
SELECT
    h.HospitalName,
    l.City,
    COUNT(cr.CallID)                         AS TotalRequests,
    SUM(cr.FeeOffered)                        AS TotalFeeOffered,
    SUM(ppc.TotalPaid)                        AS ActualAmountPaid,
    SUM(cr.FeeOffered) - SUM(ppc.TotalPaid)   AS PaymentGap
FROM HOSPITAL h
JOIN  LOCATION     l   ON l.LocationID  = h.LocationID
JOIN  CALL_REQUEST cr  ON cr.HospitalID = h.HospitalID
LEFT JOIN PaidPerCall ppc ON ppc.CallID = cr.CallID
GROUP BY h.HospitalID, h.HospitalName, l.City
ORDER BY PaymentGap DESC;


================================================================
Q9: Average Response Time by Urgency Level
    (Timestamp Arithmetic)
================================================================

QUERY TEXT:
Measure how quickly consultants accept requests grouped by
urgency level (Low, Medium, High, Emergency). The response
time is computed as the difference between AcceptanceTimestamp
and CreatedTimestamp, converted from seconds to hours using
EXTRACT(EPOCH). Rows where AcceptanceTimestamp is NULL
(not yet accepted) are excluded. This is a key SLA metric.

Primary User    : Admin / SLA Monitoring
SQL Concepts    : EXTRACT(EPOCH FROM interval) for timestamp
                  arithmetic, ROUND with NUMERIC cast, NULL
                  exclusion via WHERE.

SQL SELECT QUERY:

SELECT
    ct.UrgencyLevel,
    COUNT(a.CallID) AS TotalAssigned,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (a.AcceptanceTimestamp - cr.CreatedTimestamp))
            / 3600.0
        )::NUMERIC, 2
    ) AS AvgResponseTimeHours
FROM ASSIGNMENT    a
JOIN CALL_REQUEST cr ON cr.CallID     = a.CallID
JOIN CALL_TYPE    ct ON ct.CallTypeID = cr.CallTypeID
WHERE a.AcceptanceTimestamp IS NOT NULL
GROUP BY ct.UrgencyLevel
ORDER BY AvgResponseTimeHours;


================================================================
Q10: Consultants with No Phone on Record
     (NOT EXISTS Anti-Join)
================================================================

QUERY TEXT:
Identify consultants who have no phone number registered in the
CONSULTANT_PHONE table, making them completely unreachable via
phone through the system. NOT EXISTS is used as a safe anti-join
against the 1NF-compliant phone table. This query demonstrates
the importance of separating the multivalued phone attribute
into its own table.

Primary User    : Admin / Contact Management
SQL Concepts    : NOT EXISTS correlated subquery against
                  CONSULTANT_PHONE (anti-semi-join).

SQL SELECT QUERY:

SELECT
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName  AS ConsultantName,
    s.SpecializationName,
    ic.Status,
    ic.Email
FROM INDEPENDENT_CONSULTANT ic
JOIN SPECIALIZATION s ON s.SpecializationID = ic.SpecializationID
WHERE NOT EXISTS (
    SELECT 1 FROM CONSULTANT_PHONE cp
    WHERE cp.ConsultantID = ic.ConsultantID
)
ORDER BY ic.RegistrationDate;


================================================================
Q11: Consultants Who Have Handled Every Urgency Level
     (Relational Division)
================================================================

QUERY TEXT:
Find consultants who have at least one completed assignment
covering every urgency level that exists in the system
(Low, Medium, High, Emergency). This is implemented using
Relational Division: double NOT EXISTS with an EXCEPT set
operator. The outer NOT EXISTS checks that there is no urgency
level in the system that the consultant has NOT covered.

Primary User    : Admin / Performance Review
SQL Concepts    : Relational Division via double NOT EXISTS +
                  EXCEPT set operator, correlated subquery,
                  set difference semantics.

SQL SELECT QUERY:

SELECT
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName  AS ConsultantName,
    s.SpecializationName,
    ic.YearsOfExperience
FROM INDEPENDENT_CONSULTANT ic
JOIN SPECIALIZATION s ON s.SpecializationID = ic.SpecializationID
WHERE NOT EXISTS (
    SELECT ct.UrgencyLevel FROM CALL_TYPE ct WHERE ct.UrgencyLevel IS NOT NULL
    EXCEPT
    SELECT ct2.UrgencyLevel
    FROM  ASSIGNMENT    a
    JOIN  CALL_REQUEST cr  ON cr.CallID      = a.CallID
    JOIN  CALL_TYPE    ct2 ON ct2.CallTypeID = cr.CallTypeID
    WHERE a.ConsultantID = ic.ConsultantID
)
ORDER BY ic.YearsOfExperience DESC;


================================================================
Q12: Core Match-Making - Open Requests vs Matching Available
     Consultants
================================================================

QUERY TEXT:
For every open call request, find all active consultants whose
specialization matches the required specialization AND whose
availability slot covers the full duration of the call on that
date. The time-range join ensures the consultant's slot starts
at or before the call's start time and ends at or after the
call's end time (start + expected duration). Results are ordered
by CallID and then by years of experience descending.

Primary User    : Hospital Admin / System
SQL Concepts    : 5-table JOIN with multi-condition time-range JOIN,
                  INTERVAL arithmetic with ::text cast,
                  specialization chain join.

SQL SELECT QUERY:

SELECT
    cr.CallID,
    cr.CallDate,
    cr.StartTime,
    sp.SpecializationName,
    cr.FeeOffered,
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName  AS AvailableConsultant,
    ic.YearsOfExperience,
    avs.StartTime                        AS SlotStart,
    avs.EndTime                          AS SlotEnd
FROM CALL_REQUEST cr
JOIN SPECIALIZATION          sp ON sp.SpecializationID = cr.RequiredSpecializationID
JOIN INDEPENDENT_CONSULTANT  ic
    ON  ic.SpecializationID = sp.SpecializationID
    AND ic.Status           = 'Active'
JOIN AVAILABILITY_SLOT avs
    ON  avs.ConsultantID  = ic.ConsultantID
    AND avs.AvailableDate = cr.CallDate
    AND avs.SlotStatus    = 'Available'
    AND avs.StartTime    <= cr.StartTime
    AND avs.EndTime      >= (cr.StartTime + (cr.ExpectedDuration::text || ' minutes')::INTERVAL)
WHERE cr.Status = 'Open'
ORDER BY cr.CallID, ic.YearsOfExperience DESC;


================================================================
Q13: Full Assignment History for a Consultant with Latest
     Payment (CTE + ROW_NUMBER)
================================================================

QUERY TEXT:
Display a full personal dashboard for a specific consultant
showing every assignment they have, including hospital name,
department, call date, call type, urgency level, assignment
status, and the most recent payment record for each assignment.
ROW_NUMBER() partitioned by (CallID, ConsultantID) and ordered
by PaymentDate DESC de-duplicates multiple payment records,
keeping only the latest one per assignment.

Note: Change the ConsultantID value (1205) in the WHERE clause
to view the dashboard for a different consultant (1201-1210).

Primary User    : Consultant (My Assignments view)
SQL Concepts    : CTE (WITH clause), ROW_NUMBER() OVER window
                  function to de-duplicate payments, 5-table JOIN,
                  COALESCE.

SQL SELECT QUERY:

WITH LatestPayment AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY CallID, ConsultantID
               ORDER BY PaymentDate DESC NULLS LAST
           ) AS rn
    FROM PAYMENT
)
SELECT
    a.CallID,
    h.HospitalName,
    d.DepartmentName,
    cr.CallDate,
    cr.StartTime,
    cr.ExpectedDuration          AS DurationMinutes,
    ct.TypeName                  AS CallType,
    ct.UrgencyLevel,
    a.AssignmentStatus,
    COALESCE(lp.AmountPaid, 0)   AS AmountReceived,
    lp.PaymentStatus,
    lp.PaymentMode
FROM ASSIGNMENT a
JOIN      CALL_REQUEST  cr ON cr.CallID       = a.CallID
JOIN      HOSPITAL       h ON h.HospitalID    = cr.HospitalID
LEFT JOIN DEPARTMENT     d ON d.DepartmentID  = cr.DepartmentID
JOIN      CALL_TYPE     ct ON ct.CallTypeID   = cr.CallTypeID
LEFT JOIN LatestPayment lp
    ON  lp.CallID       = a.CallID
    AND lp.ConsultantID = a.ConsultantID
    AND lp.rn           = 1
WHERE a.ConsultantID = 1205
ORDER BY cr.CallDate DESC, cr.StartTime;


================================================================
Q14: Consultant Acceptance Rate
     (NULLIF + Conditional Aggregation)
================================================================

QUERY TEXT:
Calculate the acceptance rate for each consultant as the
percentage of their assignments that were completed versus
total assignments. NULLIF prevents a division-by-zero error
for consultants with no assignments. The result helps the admin
and quality assurance team identify reliable consultants for
contract renewal and flag those with low acceptance rates.

Primary User    : Admin / Quality Assurance
SQL Concepts    : NULLIF to prevent division-by-zero, ROUND with
                  percentage arithmetic, COUNT with CASE WHEN
                  (conditional aggregation), ORDER BY on derived
                  column.

SQL SELECT QUERY:

SELECT
    ic.ConsultantID,
    ic.FirstName || ' ' || ic.LastName  AS ConsultantName,
    s.SpecializationName,
    COUNT(*)                                                           AS TotalAssigned,
    COUNT(CASE WHEN a.AssignmentStatus = 'Completed' THEN 1 END)      AS Completed,
    COUNT(CASE WHEN a.AssignmentStatus = 'Rejected'  THEN 1 END)      AS Rejected,
    ROUND(
        100.0 * COUNT(CASE WHEN a.AssignmentStatus = 'Completed' THEN 1 END)
        / NULLIF(COUNT(*), 0),
        1
    ) AS AcceptanceRate_Pct
FROM ASSIGNMENT a
JOIN INDEPENDENT_CONSULTANT ic ON ic.ConsultantID    = a.ConsultantID
JOIN SPECIALIZATION          s  ON s.SpecializationID = ic.SpecializationID
GROUP BY ic.ConsultantID, ic.FirstName, ic.LastName, s.SpecializationName
ORDER BY AcceptanceRate_Pct DESC;


================================================================
END OF FILE
================================================================
