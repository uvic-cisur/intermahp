
# High Level selector buttons ----

# On select, deactivate other buttons and activate selected
observeEvent(input$hl_data_selector_btn, {
  toggleElement("hl_ds_div")
  hideElement("hl_fs_div")
  hideElement("hl_dc_div")
  
  toggleClass(id = "hl_data_selector_btn", class = "active")
  removeClass(id = "hl_filtration_systems_btn", class = "active")
  removeClass(id = "hl_download_chart_btn", class = "active")
})

observeEvent(input$hl_filtration_systems_btn, {
  hideElement("hl_ds_div")
  toggleElement("hl_fs_div")
  hideElement("hl_dc_div")
  
  removeClass(id = "hl_data_selector_btn", class = "active")
  toggleClass(id = "hl_filtration_systems_btn", class = "active")
  removeClass(id = "hl_download_chart_btn", class = "active")
  
})

observeEvent(input$hl_download_chart_btn, {
  hideElement("hl_ds_div")
  hideElement("hl_fs_div")
  toggleElement("hl_dc_div")
  
  removeClass(id = "hl_data_selector_btn", class = "active")
  removeClass(id = "hl_filtration_systems_btn", class = "active")
  toggleClass(id = "hl_download_chart_btn", class = "active")
  
})

# Initial show/class
showElement("hl_ds_div")
hideElement("hl_fs_div")
hideElement("hl_dc_div")

addClass(id = "hl_data_selector_btn", class = "active")
removeClass(id = "hl_filtration_systems_btn", class = "active")
removeClass(id = "hl_download_chart_btn", class = "active")