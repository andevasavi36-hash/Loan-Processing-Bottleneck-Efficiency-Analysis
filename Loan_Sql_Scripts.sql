SELECT COUNT(*) AS total_records
FROM cleaned_fct_loan_applications;


SELECT TOP 10 *
FROM cleaned_fct_loan_applications;


EXEC sp_help 'cleaned_fct_loan_applications';


SELECT *
FROM cleaned_fct_loan_applications
WHERE officer_id IS NULL;


SELECT application_id,
COUNT(*) AS DuplicateCount
FROM cleaned_fct_loan_applications
GROUP BY application_id
HAVING COUNT(*) > 1;



SELECT TOP 1 *
FROM cleaned_fct_loan_applications;



SELECT
    application_id,
    submission_date,
    end_date
FROM cleaned_fct_loan_applications;


SELECT *
FROM cleaned_fct_loan_applications
WHERE end_date IS NULL;



SELECT *
FROM cleaned_fct_loan_applications
WHERE submission_date IS NULL;



SELECT
    f.application_id,
    f.officer_id,
    f.loan_type_id,
    f.submission_date_id
FROM dbo.cleaned_fct_loan_applications AS f
LEFT JOIN dbo.[dim_loan_officer (1) (1)] AS o
    ON f.officer_id = o.officer_id
LEFT JOIN dbo.[dim_loan_type (1)] AS l
    ON f.loan_type_id = l.loan_type_id
LEFT JOIN dbo.[dim_date (1) (1)] AS d
    ON f.submission_date_id = d.date_id
WHERE o.officer_id IS NULL
   OR l.loan_type_id IS NULL
   OR d.date_id IS NULL;




SELECT TOP 1 * FROM dbo.[dim_date (1) (1)];
SELECT TOP 1 * FROM dbo.[dim_loan_officer (1) (1)];
SELECT TOP 1 * FROM dbo.[dim_loan_type (1)];




SELECT
    COUNT(*) AS InvalidRelationships
FROM dbo.cleaned_fct_loan_applications AS f
LEFT JOIN dbo.[dim_loan_officer (1) (1)] AS o
    ON f.officer_id = o.officer_id
LEFT JOIN dbo.[dim_loan_type (1)] AS l
    ON f.loan_type_id = l.loan_type_id
LEFT JOIN dbo.[dim_date (1) (1)] AS d
    ON f.submission_date_id = d.date_id
WHERE o.officer_id IS NULL
   OR l.loan_type_id IS NULL
   OR d.date_id IS NULL;



ALTER TABLE dbo.cleaned_fct_loan_applications
ADD CONSTRAINT PK_Applications
PRIMARY KEY (application_id);



ALTER TABLE dbo.[dim_date (1) (1)]
ADD CONSTRAINT PK_Date
PRIMARY KEY (date_id);



ALTER TABLE dbo.[dim_loan_officer (1) (1)]
ADD CONSTRAINT PK_Officer
PRIMARY KEY (officer_id);


ALTER TABLE dbo.[dim_loan_type (1)]
ADD CONSTRAINT PK_LoanType
PRIMARY KEY (loan_type_id);



ALTER TABLE dbo.cleaned_fct_loan_applications
ADD CONSTRAINT FK_Officer
FOREIGN KEY (officer_id)
REFERENCES dbo.[dim_loan_officer (1) (1)](officer_id);




ALTER TABLE dbo.cleaned_fct_loan_applications
ADD CONSTRAINT FK_LoanType
FOREIGN KEY (loan_type_id)
REFERENCES dbo.[dim_loan_type (1)](loan_type_id);



ALTER TABLE dbo.cleaned_fct_loan_applications
ADD CONSTRAINT FK_Date
FOREIGN KEY (submission_date_id)
REFERENCES dbo.[dim_date (1) (1)](date_id);



SELECT
    f.application_id,
    o.officer_name,
    l.loan_type,
    d.full_date
FROM dbo.cleaned_fct_loan_applications f
INNER JOIN dbo.[dim_loan_officer (1) (1)] o
ON f.officer_id=o.officer_id
INNER JOIN dbo.[dim_loan_type (1)] l
ON f.loan_type_id=l.loan_type_id
INNER JOIN dbo.[dim_date (1) (1)] d
ON f.submission_date_id=d.date_id;





SELECT
    application_id,
    submission_date,
    end_date,
    DATEDIFF(DAY, submission_date, end_date) AS Processing_Days
FROM dbo.cleaned_fct_loan_applications;



SELECT
    o.officer_name,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_Processing_Days
FROM dbo.cleaned_fct_loan_applications f
JOIN dbo.[dim_loan_officer (1) (1)] o
ON f.officer_id=o.officer_id
GROUP BY o.officer_name;



SELECT
    l.loan_type,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_Processing_Days
FROM dbo.cleaned_fct_loan_applications f
JOIN dbo.[dim_loan_type (1)] l
ON f.loan_type_id=l.loan_type_id
GROUP BY l.loan_type;




SELECT
    application_id,
    submission_date,
    LEAD(submission_date)
        OVER(ORDER BY submission_date) AS Next_Submission_Date
FROM dbo.cleaned_fct_loan_applications;




SELECT
    application_id,
    submission_date,
    LAG(submission_date)
        OVER(ORDER BY submission_date) AS Previous_Submission_Date
FROM dbo.cleaned_fct_loan_applications;




SELECT
    lt.loan_type,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_TAT_Days
FROM dbo.cleaned_fct_loan_applications AS f
INNER JOIN dbo.[dim_loan_type (1)] AS lt
    ON f.loan_type_id = lt.loan_type_id
WHERE f.end_date IS NOT NULL
GROUP BY lt.loan_type
ORDER BY Avg_TAT_Days DESC;



SELECT TOP 1
    lt.loan_type,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_TAT_Days
FROM dbo.cleaned_fct_loan_applications AS f
INNER JOIN dbo.[dim_loan_type (1)] AS lt
    ON f.loan_type_id = lt.loan_type_id
WHERE f.end_date IS NOT NULL
GROUP BY lt.loan_type
ORDER BY Avg_TAT_Days DESC;



SELECT
    o.region,
    lt.loan_type,
    COUNT(*) AS Total_Applications,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_TAT_Days
FROM dbo.cleaned_fct_loan_applications AS f
INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
    ON f.officer_id = o.officer_id
INNER JOIN dbo.[dim_loan_type (1)] AS lt
    ON f.loan_type_id = lt.loan_type_id
WHERE f.end_date IS NOT NULL
GROUP BY
    o.region,
    lt.loan_type
ORDER BY Avg_TAT_Days DESC;


WITH OfficerApplications AS
(
    SELECT
        f.officer_id,
        o.officer_name,
        COUNT(f.application_id) AS Total_Applications
    FROM dbo.cleaned_fct_loan_applications AS f
    INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
        ON f.officer_id = o.officer_id
    GROUP BY
        f.officer_id,
        o.officer_name
)
SELECT *
FROM OfficerApplications
ORDER BY Total_Applications DESC;


SELECT
    f.officer_id,
    o.officer_name,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Average_Processing_Days
FROM dbo.cleaned_fct_loan_applications AS f
INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
    ON f.officer_id = o.officer_id
WHERE f.end_date IS NOT NULL
GROUP BY
    f.officer_id,
    o.officer_name
ORDER BY Average_Processing_Days;


WITH OfficerPerformance AS
(
    SELECT
        f.officer_id,
        o.officer_name,
        COUNT(f.application_id) AS Total_Applications,
        AVG(DATEDIFF(DAY,
            f.submission_date,
            f.end_date)) AS Average_Processing_Days
    FROM dbo.cleaned_fct_loan_applications AS f
    INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
        ON f.officer_id = o.officer_id
    WHERE f.end_date IS NOT NULL
    GROUP BY
        f.officer_id,
        o.officer_name
)
SELECT
    officer_id,
    officer_name,
    Total_Applications,
    Average_Processing_Days,
    RANK() OVER (ORDER BY Average_Processing_Days ASC) AS Performance_Rank
FROM OfficerPerformance
ORDER BY Performance_Rank;








WITH OfficerPerformance AS
(
    SELECT
        f.officer_id,
        o.officer_name,
        o.region,
        COUNT(f.application_id) AS Total_Applications,
        AVG(DATEDIFF(DAY,
            f.submission_date,
            f.end_date)) AS Avg_Processing_Days
    FROM dbo.cleaned_fct_loan_applications AS f
    INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
        ON f.officer_id = o.officer_id
    WHERE f.end_date IS NOT NULL
    GROUP BY
        f.officer_id,
        o.officer_name,
        o.region
)

SELECT
    officer_id,
    officer_name,
    region,
    Total_Applications,
    Avg_Processing_Days,
    DENSE_RANK() OVER
    (
        ORDER BY
            Avg_Processing_Days ASC,
            Total_Applications DESC
    ) AS Performance_Rank
FROM OfficerPerformance
ORDER BY Performance_Rank;





SELECT
    f.application_id,
    o.officer_name,
    o.region,
    lt.loan_type,
    f.loan_amount,
    f.interest_rate,
    f.credit_score,
    f.applicant_income,
    f.submission_date,
    f.end_date,
    DATEDIFF(DAY,
        f.submission_date,
        f.end_date) AS Processing_Days
FROM dbo.cleaned_fct_loan_applications AS f
INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
    ON f.officer_id = o.officer_id
INNER JOIN dbo.[dim_loan_type (1)] AS lt
    ON f.loan_type_id = lt.loan_type_id;







CREATE VIEW vw_SpecialistPerformance
AS
SELECT
    f.officer_id,
    o.officer_name,
    o.region,
    COUNT(f.application_id) AS Total_Applications,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_Processing_Days
FROM dbo.cleaned_fct_loan_applications AS f
INNER JOIN dbo.[dim_loan_officer (1) (1)] AS o
    ON f.officer_id = o.officer_id
WHERE f.end_date IS NOT NULL
GROUP BY
    f.officer_id,
    o.officer_name,
    o.region;
GO



SELECT *
FROM vw_SpecialistPerformance;









SELECT TOP 20
    submission_date,
    end_date
FROM dbo.cleaned_fct_loan_applications;




SELECT *
FROM dbo.cleaned_fct_loan_applications
WHERE end_date < submission_date;





WITH OfficerPerformance AS
(
    SELECT
        f.officer_id,
        o.officer_name,
        o.region,
        COUNT(*) AS Total_Applications,
        AVG(
            CAST(DATEDIFF(DAY, f.submission_date, f.end_date) AS BIGINT)
        ) AS Avg_Processing_Days
    FROM dbo.cleaned_fct_loan_applications f
    INNER JOIN dbo.[dim_loan_officer (1) (1)] o
        ON f.officer_id = o.officer_id
    WHERE
        f.submission_date IS NOT NULL
        AND f.end_date IS NOT NULL
        AND f.end_date >= f.submission_date
    GROUP BY
        f.officer_id,
        o.officer_name,
        o.region
)
SELECT *,
       DENSE_RANK() OVER
       (
           ORDER BY Avg_Processing_Days ASC,
                    Total_Applications DESC
       ) AS Performance_Rank
FROM OfficerPerformance;



SELECT
    o.officer_name,
    o.region,
    COUNT(*) AS Applications,
    AVG(DATEDIFF(DAY,
        f.submission_date,
        f.end_date)) AS Avg_TAT
FROM dbo.cleaned_fct_loan_applications f
JOIN dbo.[dim_loan_officer (1) (1)] o
ON f.officer_id=o.officer_id
GROUP BY
    o.officer_name,
    o.region
ORDER BY Avg_TAT DESC;



SELECT
    application_id,
    officer_id,
    loan_amount,
    DENSE_RANK() OVER
    (
        PARTITION BY officer_id
        ORDER BY loan_amount DESC
    ) AS Loan_Rank
FROM dbo.cleaned_fct_loan_applications;