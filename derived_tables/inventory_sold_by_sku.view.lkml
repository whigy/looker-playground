view: inventory_sold_by_sku {
  derived_table: {
    sql: SELECT
       product_sku AS product_sku
      ,SUM(cost) AS total_cost
      ,SUM(CASE WHEN sold_at is not null THEN cost ELSE
NULL END) AS cost_of_goods_sold
FROM public.inventory_items
GROUP BY 1
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: product_sku {
    primary_key: yes
    type: string
    sql: ${TABLE}."PRODUCT_SKU" ;;
  }

  dimension: total_cost {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  dimension: cost_of_goods_sold {
    type: number
    sql: ${TABLE}."COST_OF_GOODS_SOLD" ;;
  }

  set: detail {
    fields: [product_sku, total_cost, cost_of_goods_sold]
  }
}
