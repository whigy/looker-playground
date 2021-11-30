# If necessary, uncomment the line below to include explore_source.
# include: "huijie_case_study_playground.model.lkml"
explore: user_order_facts {}
view: user_order_facts {
  label: "User Order Fact Table"
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: count_of_orders {}
      column: total_sale_price {}
      column: first_order_date {}
      column: latest_order_date {}
    }
  }
  dimension: user_id {
    primary_key: yes
    label: "User ID"
    view_label: "ID"
    type: number
  }
  dimension: count_of_orders {
    type: number
  }
  dimension: total_sale_price {
    value_format: "$#,##0.00"
    type: number
  }
  dimension: first_order_date {
    type: date
  }
  dimension: latest_order_date {
    type: date
  }

  dimension: count_of_orders_bucket {
    type: tier
    sql: ${count_of_orders} ;;
    tiers: [2,3,6,10]
    style: integer
  }

  dimension: day_since_last_order {
    type: duration_day
    sql_start: ${latest_order_date};;
    sql_end: CURRENT_DATE ;;
  }

  dimension: is_active_user {
    type: yesno
    sql: ${day_since_last_order} <= 90 ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${count_of_orders} > 1 ;;
  }

  measure: count_star {
    type: count
  }

  measure: average_days_since_last_order {
    type: average
    sql: ${day_since_last_order} ;;
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${count_of_orders} ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${count_of_orders} ;;
  }

  measure: total_lifetime_revenue {
    type: sum
    sql: ${total_sale_price} ;;
    value_format_name: usd
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${total_sale_price} ;;
    value_format_name: usd
  }
}


# view: user_order_facts {
#   derived_table: {
#     sql: SELECT
#         order_items."USER_ID"  AS "order_items.user_id",
#         COUNT(DISTINCT (order_items."ORDER_ID") ) AS "order_items.count_of_orders",
#         COALESCE(SUM((order_items."SALE_PRICE") ), 0) AS "order_items.total_sale_price",
#         TO_CHAR(TO_DATE(MIN((TO_CHAR(TO_DATE(order_items."CREATED_AT" ), 'YYYY-MM-DD'))) ), 'YYYY-MM-DD') AS "order_items.first_order_date",
#         TO_CHAR(TO_DATE(MAX((TO_CHAR(TO_DATE(order_items."CREATED_AT" ), 'YYYY-MM-DD'))) ), 'YYYY-MM-DD') AS "order_items.latest_order_date"
#       FROM "PUBLIC"."ORDER_ITEMS" AS order_items
#       GROUP BY 1
#       ORDER BY 2 DESC
#       LIMIT 10
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: order_items_user_id {
#     type: number
#     sql: ${TABLE}."order_items.user_id" ;;
#   }

#   dimension: order_items_count_of_orders {
#     type: number
#     sql: ${TABLE}."order_items.count_of_orders" ;;
#   }

#   dimension: order_items_total_sale_price {
#     type: number
#     sql: ${TABLE}."order_items.total_sale_price" ;;
#   }

#   dimension: order_items_first_order_date {
#     type: string
#     sql: ${TABLE}."order_items.first_order_date" ;;
#   }

#   dimension: order_items_latest_order_date {
#     type: string
#     sql: ${TABLE}."order_items.latest_order_date" ;;
#   }

#   set: detail {
#     fields: [order_items_user_id, order_items_count_of_orders, order_items_total_sale_price, order_items_first_order_date, order_items_latest_order_date]
#   }
# }
