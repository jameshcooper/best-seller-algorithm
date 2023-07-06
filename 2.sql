use CrowdSourced;

-- each customers top 3 items   
select
    c1.Customer_ID,
    c1.SKU 'SKU_1',
    c2.SKU 'SKU_2',
    c3.SKU 'SKU_3' into faves_top3
from
    cust_clothing_all c1
    inner join cust_clothing_all c2 on (
        c2.Customer_ID = c1.Customer_ID
        and c2.rank = 2
    )
    inner join cust_clothing_all c3 on (
        c3.Customer_ID = c1.Customer_ID
        and c3.rank = 3
    )
where
    c1.rank = 1;
