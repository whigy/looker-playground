connection: "snowlooker"

# include all the views
include: "/views/**/*.view"
include: "/derived_tables/**/*.view"

datagroup: huijie_case_study_playground_default_datagroup { # model level datagroup
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

datagroup: user_datagroup { # explore level data group
  sql_trigger: SELECT CURRENT_DATE();; # refresh daily
  max_cache_age: "24 hour"
}

datagroup: order_items_datagroup {
  sql_trigger: SELECT created FROM order_items_datagroup ;;
  max_cache_age: "4 hour"
}

persist_with: huijie_case_study_playground_default_datagroup # model level datagroup

explore: distribution_centers {}

explore: etl_jobs {}

explore: events {
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
    # fields: [-customer_with_return_rate]
  }
}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {
  view_label: "Order Items"
  sql_always_where: ${status} != 'Returned' ;; # This filter is not changable by users
  sql_always_having: ${total_sale_price} >= 200 ;; # This filter is not changable by users
  # always_filter: {
  #   filters: [order_items.created_date: "before 1 day ago"]
  # }
  conditionally_filter: {
    filters: [order_items.created_date: "2 year"]
    unless: [user_id]
  }
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: users {
  persist_with: user_datagroup
  join: order_items {
    fields: [-margin]
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: one_to_many
  }
}
