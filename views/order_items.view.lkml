view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: margin {
    type: number
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_sale_price {
    type: sum
    sql:  ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    type: average
    sql:  ${sale_price} ;;
    value_format_name: usd
  }

  measure: cumulative_total_sales {
    type: running_total
    sql:  ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    type: sum
    sql:  ${sale_price} ;;
    value_format_name: usd
    filters: [status: "-Cancelled, -Returned"]
  }

  measure: total_gross_margin {
    type: sum
    sql:  ${margin} ;;
    value_format_name: usd
  }

  measure: average_gross_margin {
    type: average
    sql:  ${margin} ;;
    value_format_name: usd
    filters: [status: "Complete"]  # needed?
  }

  measure: gross_margin_percentage {
    type: number
    sql: ${total_gross_margin} / NULLIFZERO(${total_gross_revenue}) ;;
    value_format_name: percent_0
  }

  measure: number_of_items_returned {
    type: count_distinct
    filters: [status: "Returned"]
    sql: ${id} ;;
  }

  measure: number_of_items_sold {
    type: count_distinct
    filters: [status: "Complete, Processing"]
    sql: ${id} ;;
  }

  measure: items_return_rate {
    type: number
    sql: ${number_of_items_returned} / NULLIFZERO(${number_of_items_sold});;
    value_format_name: percent_0
  }

  measure: number_of_custiomer_with_return{
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: custiomer_with_return_rate{
    type: number
    sql: ${number_of_custiomer_with_return} / users.count ;;
    value_format_name: percent_0
  }

  measure: average_spend_per_customer {
    type: number
    sql: ${total_sale_price} / users.count ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.first_name,
      users.id,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}