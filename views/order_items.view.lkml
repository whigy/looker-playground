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

  dimension_group: shipping_days {
    type: duration
    sql_start: ${shipped_date} ;;
    sql_end: ${delivered_date} ;;
    intervals: [day]
  }

  # SAME AS dimension_group
  dimension: shipping_days2 {
    type: number
    sql: DATEDIFF(DAY, ${shipped_date},${delivered_date});;
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

  # dimension: user_order_sequence { # This is not how it works
  #   type: number
  #   sql: row_number() over (PARTITION BY ${order_items.user_id} order by ${order_items.created_raw} asc) ;;
  # }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_sale_price {
    description: "Sum of sale price"
    type: sum
    sql:  ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_margin {
    type: sum
    sql: ${margin} ;;
  }

  measure: average_sale_price {
    description: "Average of sale price"
    type: average
    sql:  ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_sales_email_traffic {
    description: "total sales for only users that came to the website via the Email traffic source"
    type: sum
    sql: ${sale_price} ;;
    filters:  [users.traffic_source: "Email"]
  }

  measure: percentage_sales_email_traffic {
    description: "percentage of sales that are attributed to users coming from the email traffic source"
    type: number
    value_format_name: percent_2
    sql: 1.0* ${total_sales_email_traffic} / NULLIF(${total_sale_price} , 1) ;;
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

  measure: number_of_items {
    description: "Count of items"
    type: count_distinct
    sql: ${id} ;;
  }

  measure: number_of_items_returned {
    type: count_distinct
    filters: [status: "Returned"]
    sql: ${id} ;;
  }

  measure: number_of_customer_with_return {
    type: count_distinct
    filters: [status: "Returned"]
    sql: ${user_id} ;;
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

  measure: customer_with_return_rate {
    type: number
    sql: ${number_of_customer_with_return} / ${users.count} ;;
    value_format_name: percent_0
  }

  measure: average_spend_per_customer {
    type: number
    sql: ${total_sale_price} / ${users.count} ;;
  }

  measure: number_of_orders {
    description: "Count of unique orders"
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: first_order_date {
    type: date
    sql: MIN(${created_date}) ;;
  }

  measure: latest_order_date {
    type: date
    sql: MAX(${created_date}) ;;
  }

  # ----- Parameters ------
  parameter: select_timeframe {
    type: unquoted
    default_value: "created_month"
    allowed_value: {
      value: "created_date"
      label: "Date"
    }
    allowed_value: {
      value: "created_week"
      label: "Week"
    }
    allowed_value: {
      value: "created_month"
      label: "Month"
    }
  }

  dimension: dynamic_timeframe {
    label_from_parameter: select_timeframe
    type: string
    sql:
    {% if select_timeframe._parameter_value == 'created_date' %}
    ${created_date}
    {% elsif select_timeframe._parameter_value == 'created_week' %}
    ${created_week}
    {% else %}
    ${created_month}
    {% endif %} ;;
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
