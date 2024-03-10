DROP Table Timestamp;
CREATE TABLE Timestamp AS
SELECT (substr(mfp.timestamp, 1, 4) || '-' || 
        substr(mfp.timestamp, 5, 2) || '-' || 
        substr(mfp.timestamp, 7, 2)) as mfp_date, mfp.timestamp,
        (substr(qsh.timestamp, 1, 4) || '-' || 
        substr(qsh.timestamp, 5, 2) || '-' || 
        substr(qsh.timestamp, 7, 2)) as qsh_date, qsh.timestamp,
        (substr(qss.timestamp, 1, 4) || '-' || 
        substr(qss.timestamp, 5, 2) || '-' || 
        substr(qss.timestamp, 7, 2)) as qss_date, qss.timestamp,
        (substr(cds.timestamp, 1, 4) || '-' || 
        substr(cds.timestamp, 5, 2) || '-' || 
        substr(cds.timestamp, 7, 2)) as cds_date, cds.timestamp
    from  mfp_daily_summary
    FULL OUTER JOIN mfp_daily_summary as mfp USING (timestamp = ts.timestamp,
    FULL OUTER JOIN apple_qs_health_data as qsh USING(timestamp)
    FULL OUTER JOIN apple_qs_health_data as qss USING(timestamp)
    FULL OUTER JOIN cronometer_dailysummary as cds USING(timestamp)
