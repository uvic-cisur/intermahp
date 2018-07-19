# Analyst selector buttons ----

# On select, deactivate other buttons and activate selected
observeEvent(input$a_data_selector_btn, {
  toggleElement("a_ds_div")
  hideElement("a_fs_div")
  hideElement("a_dc_div")
  
  toggleClass(id = "a_data_selector_btn", class = "active")
  removeClass(id = "a_filtration_systems_btn", class = "active")
  removeClass(id = "a_download_table_btn", class = "active")
})

observeEvent(input$a_filtration_systems_btn, {
  hideElement("a_ds_div")
  toggleElement("a_fs_div")
  hideElement("a_dc_div")
  
  removeClass(id = "a_data_selector_btn", class = "active")
  toggleClass(id = "a_filtration_systems_btn", class = "active")
  removeClass(id = "a_download_table_btn", class = "active")
  
})

observeEvent(input$a_download_table_btn, {
  hideElement("a_ds_div")
  hideElement("a_fs_div")
  toggleElement("a_dc_div")
  
  removeClass(id = "a_data_selector_btn", class = "active")
  removeClass(id = "a_filtration_systems_btn", class = "active")
  toggleClass(id = "a_download_table_btn", class = "active")
  
})

# Initial show/class
showElement("a_ds_div")
hideElement("a_fs_div")
hideElement("a_dc_div")

addClass(id = "a_data_selector_btn", class = "active")
removeClass(id = "a_filtration_systems_btn", class = "active")
removeClass(id = "a_download_table_btn", class = "active")