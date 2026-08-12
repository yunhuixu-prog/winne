select date_p,compute_unit
    ,mau
from stat_sdk.filing_amz_overview_metrics
where business_unit='整体' and compute_unit!='整体'
	and business_line_p='airbrush' and business_series_p='key_countries'
    and date_p between 20260101 and 20260401