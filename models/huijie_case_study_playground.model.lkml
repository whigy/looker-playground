connection: "looker_partner_demo"

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
  sql_trigger: SELECT created FROM order_items ;;
  max_cache_age: "4 hour"
}

persist_with: huijie_case_study_playground_default_datagroup # model level datagroup

explore: distribution_centers {}

explore: events {
  view_label: "_Events"
  # group_label: "Huijie case study playground"
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
    fields: [-total_lifetime_orders, -total_lifetime_orders_bucket]
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
  view_label: "_Order Items"
  # sql_always_where: ${status} != 'Returned' ;; # This filter is not changable by users
  # sql_always_having: ${total_sale_price} >= 200 ;; # This filter is not changable by users
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
    # fields: [-total_lifetime_orders, -total_lifetime_orders_bucket]
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

  join: brand_order_facts_ndt {
    type: left_outer
    sql_on: ${brand_order_facts_ndt.brand} = ${products.brand} ;;
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
  # access_filter: { # this is not set up in user attributes
  #   field:state
  #   user_attribute: state
  # }
  persist_with: user_datagroup
  join: order_items {
    fields: [-margin]
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: one_to_many
  }
}

explore: order_user_fact {}
