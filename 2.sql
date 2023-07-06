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

--  if sku 3 is of the same category as sku 1 and 2 then display an item from another category
--- have other items been purchased from different cats?
select
    a.Customer_ID into items_other_cats
from
    cust_clothing_all a
    inner join items i on i.SKU = a.SKU
group by
    a.Customer_ID
having
    count(distinct i.Category) > 1;

--- select the next sku from a different category
select
    a.Customer_ID,
    a.SKU into sku3_next_item
from
    (
        select
            a.Customer_ID,
            d.SKU,
            row_number() over (
                partition by a.Customer_ID
                order by
                    d.tp desc,
                    d.ts desc
            ) 'next_sku'
        from
            (
                select
                    a.Customer_ID
                from
                    (
                        select
                            a.Customer_ID,
                            case
                                when i3.Category = i1.Category
                                and i3.Category = i2.Category then 1
                                else 0
                            end 'same_category'
                        from
                            items_other_cats a
                            inner join faves_top3 b on b.Customer_ID = a.Customer_ID
                            inner join items i1 on i1.SKU = b.SKU_1
                            inner join items i2 on i2.SKU = b.SKU_2
                            inner join items i3 on i3.SKU = b.SKU_3
                    ) a
                where
                    a.same_category = 1
            ) a
            inner join faves_top3 b on b.Customer_ID = a.Customer_ID
            inner join items c on c.SKU = b.SKU_1
            inner join cust_clothing_all d on d.Customer_ID = a.Customer_ID
            inner join items e on (
                e.SKU = d.SKU
                and e.Category != c.Category
            )
    ) a
where
    a.next_sku = 1;

update
    f
set
    f.SKU_3 = s.SKU
from
    faves_top3 f
    inner join sku3_next_item s on s.Customer_ID = f.Customer_ID;