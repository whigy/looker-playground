view: inventory_sold_by_catagory {
# If necessary, uncomment the line below to include explore_source.
# include: "huijie_case_study_playground.model.lkml"

  derived_table: {
    explore_source: inventory_items {
      column: product_category {}
      column: total_cost {}
      column: cost_of_goods_sold {}
    }
  }
  dimension: product_category {}
  dimension: total_cost {
    value_format_name: usd
    type: number
  }
  dimension: cost_of_goods_sold {
    value_format_name: usd
    type: number
  }
}
