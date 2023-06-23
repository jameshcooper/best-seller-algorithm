use DataWarehouse;

declare @shop_finish date = dateadd(dd, -1, getdate());

declare @shop_start date = dateadd(dd, -183, getdate());

select
    cs.*,
    ROW_NUMBER() over (
        PARTITION by cs.Customer_ID
        order by
            cs.tp desc,
            cs.ts desc
    ) 'rank' into CrowdSourced.dbo.cust_items_all
from
    (
        select
            th.Customer_ID,
            ti.SKU,
            count(distinct th.Transaction_ID) 'tp', --how many times purchased
            sum(ti.Item_Quantity) 'ip', --how many items purchased
            sum(ti.Item_Revenue) 'ts' --total spend
        from
            Transaction_Header th with (nolock)
            inner join Entity e with (nolock) on (
                e.Entity_ID = th.Entity_ID
                and e.Entity_Brand in ('Acme Incorporated', 'Wayne Industries')
            )
            inner join Transaction_Item ti with (nolock) on ti.Transaction_ID = th.Transaction_ID
        where
            th.Transaction_Type in (100001, 100002, 100003)
            and th.Transaction_Date >= @shop_start
            and th.Transaction_Date < @shop_finish
        group by
            th.Customer_ID,
            ti.SKU
    ) cs;


select
    a.Customer_ID,
    case
        when a.CLOTHING_TYPE_Jacket >= 1
        and a.CLOTHING_TYPE_Trousers >= 1 then 3
        when a.CLOTHING_TYPE_Jacket >= 1
        and a.CLOTHING_TYPE_Trousers >= 0 then 2
        when a.CLOTHING_TYPE_Jacket >= 0
        and a.CLOTHING_TYPE_Trousers >= 1 then 1
        else 0
    end 'CLOTHING_TYPE',
    case
        when a.CLOTHING_QUALITY_PREMIUM >= 1 then 3
        when a.CLOTHING_QUALITY_STANDARD >= 1 then 2
        when a.CLOTHING_QUALITY_ESSENTIAL >= 1 then 1
        else 0
    end 'CLOTHING_QUALITY' into CrowdSourced.dbo.cust_clothing_all
from
    (
        select
            th.Customer_ID,
            sum(
                case
                    when i.SubCategory1 = 'Clothing Premium Jacket'
                    or i.SubCategory1 = 'Clothing Standard Jacket'
                    or i.SubCategory1 = 'Clothing Essential Jacket' then 1
                    else 0
                end
            ) 'CLOTHING_TYPE_JACKET',
            sum(
                case
                    when i.SubCategory1 = 'Clothing Premium Trousers'
                    or i.SubCategory1 = 'Clothing Standard Trousers'
                    or i.SubCategory1 = 'Clothing Essential Trousers' then 1
                    else 0
                end
            ) 'CLOTHING_TYPE_TROUSERS',
            sum(
                case
                    when i.SubCategory1 = 'Clothing Premium Jacket'
                    or i.SubCategory1 = 'Clothing Premium Trousers' then 1
                    else 0
                end
            ) 'CLOTHING_QUALITY_PREMIUM',
            sum(
                case
                    when i.SubCategory1 = 'Clothing Standard Jacket'
                    or i.SubCategory1 = 'Clothing Standard Trousers' then 1
                    else 0
                end
            ) 'CLOTHING_QUALITY_STANDARD',
            sum(
                case
                    when i.SubCategory1 = 'Dog Clothing Essential Jacket'
                    or i.SubCategory1 = 'Dog Clothing Essential Trousers' then 1
                    else 0
                end
            ) 'CLOTHING_QUALITY_ESSENTIAL'
        from
            Transaction_Header th with (nolock)
            inner join Entity e with (nolock) on (
                e.Entity_ID = th.Entity_ID
                and e.Entity_Brand in ('Acme Incorporated', 'Wayne Industries')
            )
            inner join Transaction_Item ti with (nolock) on ti.Transaction_ID = th.Transaction_ID
            inner join Item i with (nolock) on i.Item_ID = ti.Item_ID
        where
            th.Transaction_Type in (100001, 100002, 100003)
            and th.Transaction_Date >= @shop_start
            and th.Transaction_Date < @shop_finish
        group by
            th.Customer_ID
    ) a;
