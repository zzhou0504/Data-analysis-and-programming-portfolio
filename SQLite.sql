SELECT roster.edited_sex,
cps.educational_attainment,
SUM(
(activity_code/100 IN (201,202,203,204,205,206,207,208,209))*duration/60.0
)/COUNT(*) AS avg_hh_activity
FROM roster
JOIN cps ON
roster.case_id=cps.case_id AND
roster.line_no=cps.line_no
JOIN activities ON
roster.case_id=activities.case_id
WHERE educational_attainment>-1
GROUP BY roster.edited_sex, cps.educational_attainment
;
