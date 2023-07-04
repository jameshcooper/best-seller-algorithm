use CrowdSourced;

-- each customers top 3 items   
select
    c1.Customer_ID,
    c1.UPC 'SKU_1',
    c2.UPC 'SKU_2',
    c3.UPC 'SKU_3' into CrowdSourced.dbo.faves_top3
from
    CrowdSourced.dbo.cust_clothing_all c1
    inner join CrowdSourced.dbo.cust_clothing_all c2 on (
        c2.Customer_ID = c1.Customer_ID
        and c2.rank = 2
    )
    inner join CrowdSourced.dbo.cust_clothing_all c3 on (
        c3.Customer_ID = c1.Customer_ID
        and c3.rank = 3
    )
where
    c1.rank = 1;